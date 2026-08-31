//
//  PromoOffersService.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import Foundation
import Logging
import PIAAccount
import PIALibrary
import StoreKit

private let log = PIALogger.logger(for: PromoOffersService.self)

/// Stateless orchestrator for the Apple promotional-offer flow:
/// eligibility → display → sign → purchase. Talks to the shared `Client.store` (StoreKit) and
/// `Client.nativeAccountAPI` (backend) only.
///
/// The three steps are separate calls on purpose: per the backend contract, signing happens when the
/// offer is *displayed*, not when it is purchased, so the sign round-trip is not paid inside the
/// user's tap.
@MainActor
final class PromoOffersService {

    enum ServiceError: LocalizedError {
        case noReceipt
        case offersDisabled
        case notEligible
        case productNotFound(String)
        case malformedSignature
        case purchase(ClientError)
        case backend(code: Int, message: String?)
        case unknown(error: Error)

        var errorDescription: String? {
            switch self {
            case .noReceipt:
                return "No current or expired subscription found on this Apple ID — nothing to send."
            case .offersDisabled:
                return "Promotional offers are disabled server-side (kill switch)."
            case .notEligible:
                return "Not eligible for this offer. Re-run eligibility."
            case .productNotFound(let id):
                return "App Store returned no product for identifier \(id)."
            case .malformedSignature:
                return "The signing response could not be decoded into a StoreKit signature."
            case .purchase(let error):
                return "Purchase failed: \(error)."
            case .backend(let code, let message):
                return "Backend error \(code): \(message ?? "no message")."
            case .unknown(let error):
                return "Unknown error: \(error)."
            }
        }
    }

    /// One promotional offer the backend said this user may redeem, on the product it belongs to.
    struct EligibleOffer {
        let productIdentifier: String
        /// The product's own localized price, for the renewal disclaimer. `nil` when the App Store
        /// returned no price.
        let displayPrice: String?
        let offer: InAppPromotionalOffer
    }

    // MARK: Step 1 — eligibility

    /// Fetches the subscription products, asks the backend which offers the user is eligible for, and
    /// matches those identifiers against each product's promotional offers (the StoreKit 2 equivalent
    /// of `SKProduct.discounts`, per Apple's *Implementing promotional offers* doc).
    ///
    /// Returns an empty array for every "no offer to show" outcome — no receipt on this Apple ID, an
    /// empty eligibility response, the server-side kill switch (HTTP 404), or an eligibility error.
    /// Only a total product-fetch failure throws.
    func eligibleOffers(country: String?) async throws(ServiceError) -> [EligibleOffer] {
        let identifiers = Set([
            AppConstants.InApp.monthlyProductIdentifier,
            AppConstants.InApp.yearlyProductIdentifier
        ])

        let products = try await fetchProducts(identifiers)
        let eligibleIdentifiers = await eligibleOfferIdentifiers(country: country)
        guard !eligibleIdentifiers.isEmpty else { return [] }

        var offers: [EligibleOffer] = []
        for product in products {
            let displayPrice = (product.native as? Product)?.displayPrice
            for offer in await Client.store.promotionalOffers(for: product)
            where eligibleIdentifiers.contains(offer.id) {
                offers.append(
                    EligibleOffer(
                        productIdentifier: product.identifier,
                        displayPrice: displayPrice,
                        offer: offer
                    ))
            }
        }

        return offers
    }

    /// The offer identifiers the backend says this user may redeem, or `[]` for any reason it cannot
    /// say — the banner treats "no offers" and "eligibility unavailable" identically.
    private func eligibleOfferIdentifiers(country: String?) async -> [String] {
        guard let jws = await Client.store.latestSubscriptionJWS(), !jws.value.isEmpty else {
            log.debug("No current or expired subscription on this Apple ID — no receipt to check eligibility")
            return []
        }

        do {
            let response = try await Client.nativeAccountAPI.promoOffersEligibility(
                receipt: jws,
                country: country
            )
            if let reason = response.reason {
                log.debug("Eligibility reason: \(reason)")
            }
            // TODO: sync with backend to only include "autobilloff" offers
            return response.offerIdentifiers.filter { $0.contains("autobilloff") }
        } catch let error as PIAError where error.type == .http(status: 404) {
            log.debug("Promotional offers disabled server-side (404)")
            return []
        } catch {
            log.error("Eligibility failed: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: Step 3 — sign

    /// Asks the backend to sign one offer. The signature's nonce is single-use and its timestamp is
    /// time-sensitive, so a signature that goes unused has to be requested again.
    ///
    /// `appAccountToken` must be the exact value the purchase then sends.
    func sign(
        productIdentifier: String,
        offerIdentifier: String,
        appAccountToken: UUID,
        country: String?
    ) async throws(ServiceError) -> InAppPromotionalOfferSignature {
        guard let jws = await Client.store.latestSubscriptionJWS() else {
            throw ServiceError.noReceipt
        }

        let signed: PromoOffersSignResponse
        do {
            signed = try await Client.nativeAccountAPI.promoOffersSign(
                receipt: jws,
                productIdentifier: productIdentifier,
                offerIdentifier: offerIdentifier,
                appAccountToken: appAccountToken,
                country: country
            )
        } catch let error as PIAError {
            switch error.type {
            case .http(status: 403): throw ServiceError.notEligible
            case .http(status: 404): throw ServiceError.offersDisabled
            default: throw ServiceError.backend(code: error.type.code, message: error.localizedDescription)
            }
        } catch {
            throw ServiceError.unknown(error: error)
        }

        guard
            let signatureData = Data(base64Encoded: signed.signature),
            let nonce = UUID(uuidString: signed.nonce)
        else {
            throw ServiceError.malformedSignature
        }

        return InAppPromotionalOfferSignature(
            offerID: offerIdentifier,
            keyID: signed.keyIdentifier,
            nonce: nonce,
            signature: signatureData,
            timestamp: signed.timestamp
        )
    }

    // MARK: Step 4 — purchase

    /// Attaches `signature` to the purchase so the App Store applies the discount.
    func purchase(
        productIdentifier: String,
        signature: InAppPromotionalOfferSignature,
        appAccountToken: UUID
    ) async throws(ServiceError) {
        let product = try await product(for: productIdentifier)
        let result = await Client.store.purchase(
            product: product,
            promotionalOffer: signature,
            appAccountToken: appAccountToken
        )

        switch result {
        case .success(let transaction):
            Client.store.finishTransaction(transaction, success: true)
            logOfferMetadata(of: transaction)
        case .failure(let error):
            throw ServiceError.purchase(error)
        }
    }

    // MARK: Helpers

    private func fetchProducts(_ identifiers: Set<String>) async throws(ServiceError) -> [any InAppProduct] {
        switch await Client.store.fetchProducts(identifiers: identifiers) {
        case .success(let products):
            return products
        case .failure(let error):
            throw ServiceError.backend(code: 606, message: "fetchProducts failed: \(error)")
        }
    }

    private func product(for identifier: String) async throws(ServiceError) -> any InAppProduct {
        guard let product = try await fetchProducts([identifier]).first(where: { $0.identifier == identifier })
        else {
            throw ServiceError.productNotFound(identifier)
        }
        return product
    }

    /// Reads back the offer metadata Apple stamped onto the transaction — the ground-truth check that
    /// the discount applied (`offerType` should be 2 / promotional, with our `offerID`).
    private func logOfferMetadata(of transaction: any InAppTransaction) {
        guard let native = transaction.native as? Transaction else {
            log.debug("Purchased, but could not read the native transaction")
            return
        }
        let offerType = native.offerType.map { "\($0.rawValue)" } ?? "nil"
        let offerID = native.offerID ?? "nil"
        log.debug(
            "Purchased transaction \(native.id) for \(native.productID): offerType \(offerType) (2 = promotional), offerID \(offerID)"
        )
    }
}
