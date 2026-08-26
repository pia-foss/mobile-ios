//
//  PromoOffersService.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  Proof-of-concept only: exercises the Apple promotional (win-back) offer business logic
//  end-to-end. Not wired into the shipping app and intentionally does not follow the project's
//  UI/architecture conventions.
//

import Foundation
import PIAAccount
import PIALibrary
import StoreKit

/// Thin orchestrator for the Apple promotional-offer flow:
/// eligibility → display → sign → purchase. Talks to the shared `Client.store` (StoreKit) and
/// `Client.nativeAccountAPI` (backend) only.
@MainActor
final class PromoOffersService {

    enum ServiceError: LocalizedError {
        case noReceipt
        case offersDisabled
        case notEligible
        case productNotFound(String)
        case malformedSignature
        case backend(code: Int, message: String?)
        case purchase(String)

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
            case .backend(let code, let message):
                return "Backend error \(code): \(message ?? "no message")."
            case .purchase(let message):
                return "Purchase failed: \(message)."
            }
        }
    }

    /// One subscription product plus the promotional offers (StoreKit's `discounts`) the user is
    /// eligible to redeem on it.
    struct ProductRow: Identifiable {
        let id: String  // product identifier
        let label: String  // "Monthly" / "Yearly"
        /// Whether the App Store returned this product.
        let available: Bool
        let displayName: String?
        let displayPrice: String?
        /// Offers configured on the product (`discounts`) that the backend also said are eligible.
        let eligibleOffers: [(offer: InAppPromotionalOffer, eligible: Bool)]
    }

    struct Catalog {
        let receiptJWS: String?
        let offerIdentifiers: [String]
        /// A human note about eligibility (reason / disabled / no-receipt), if any.
        let note: String?
        let rows: [ProductRow]
    }

    // MARK: Step 1 — load products and match eligible offers

    /// Fetches the monthly + yearly products, asks the backend which offers the user is eligible
    /// for, and matches those identifiers against each product's promotional offers (the StoreKit 2
    /// equivalent of `SKProduct.discounts`, per Apple's *Implementing promotional offers* doc).
    ///
    /// Eligibility failures are **soft**: the products still load (shown disabled) with an
    /// explanatory `note`. Only a total product-fetch failure throws.
    func loadCatalog(country: String?) async throws -> Catalog {
        let products = [
            ("Monthly", AppConstants.InApp.monthlyProductIdentifier),
            ("Yearly", AppConstants.InApp.yearlyProductIdentifier),
        ]

        let fetch = await Client.store.fetchProducts(identifiers: Set(products.map { $0.1 }))
        let fetched: [any InAppProduct]
        switch fetch {
        case .success(let value): fetched = value
        case .failure(let error): throw ServiceError.backend(code: 606, message: "fetchProducts failed: \(error)")
        }

        for fetchedProduct in fetched {
            if let product = fetchedProduct.native as? Product {
                if let offers = product.subscription?.promotionalOffers {
                    print(product.id)
                    print(offers)
                    print("----")
                }
            }
        }

        // Eligibility (soft-fail so products always display).
        var offerIdentifiers: [String] = []
        var note: String?
        var receiptJWS: String?
        if let jws = await Client.store.latestSubscriptionJWS() {
            receiptJWS = jws.value
            do {
                let response = try await  Client.nativeAccountAPI.promoOffersEligibility(
                    receipt: jws,
                    country: country
                )
                offerIdentifiers = response.offerIdentifiers
                note = response.reason
            } catch let error as PIAError {
                note =
                    error.type == .http(status: 404)
                    ? "Offers disabled server-side (404)."
                    : "Eligibility error \(error.type): \(error.localizedDescription)"
            }
        } else {
            note = "No current or expired subscription on this Apple ID — no receipt to check eligibility."
        }

        var rows: [ProductRow] = []
        for (label, identifier) in products {
            guard let product = fetched.first(where: { $0.identifier == identifier }) else {
                rows.append(
                    ProductRow(
                        id: identifier, label: label, available: false,
                        displayName: nil, displayPrice: nil, eligibleOffers: []))
                continue
            }
            let native = product.native as? Product
            let offers = await Client.store.promotionalOffers(for: product)
            let eligible = offers.map { (offer: $0, eligible: offerIdentifiers.contains($0.id)) }
            rows.append(
                ProductRow(
                    id: identifier, label: label, available: true,
                    displayName: native?.displayName, displayPrice: native?.displayPrice,
                    eligibleOffers: eligible))
        }

        return Catalog(receiptJWS: receiptJWS, offerIdentifiers: offerIdentifiers, note: note, rows: rows)
    }

    // MARK: Step 2 + 3 — sign and purchase

    /// - Returns: a human-readable summary of the resulting transaction (for the PoC log).
    func signAndPurchase(
        productIdentifier: String,
        offerIdentifier: String,
        appAccountToken: UUID,
        country: String?
    ) async throws -> String {
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
            throw ServiceError.backend(code: 0, message: error.localizedDescription)
        }

        guard
            let signatureData = Data(base64Encoded: signed.signature),
            let nonce = UUID(uuidString: signed.nonce)
        else {
            throw ServiceError.malformedSignature
        }

        let signature = InAppPromotionalOfferSignature(
            offerID: offerIdentifier,
            keyID: signed.keyIdentifier,
            nonce: nonce,
            signature: signatureData,
            timestamp: signed.timestamp
        )

        let product = try await product(for: productIdentifier)
        let result = await Client.store.purchase(
            product: product,
            promotionalOffer: signature,
            appAccountToken: appAccountToken
        )

        switch result {
        case .success(let transaction):
            Client.store.finishTransaction(transaction, success: true)
            return summary(for: transaction)
        case .failure(let error):
            throw ServiceError.purchase(error.localizedDescription)
        }
    }

    // MARK: Helpers

    private func product(for identifier: String) async throws -> any InAppProduct {
        let result = await Client.store.fetchProducts(identifiers: [identifier])
        switch result {
        case .success(let products):
            guard let product = products.first(where: { $0.identifier == identifier }) else {
                throw ServiceError.productNotFound(identifier)
            }
            return product
        case .failure(let error):
            throw ServiceError.backend(code: 606, message: "fetchProducts failed: \(error)")
        }
    }

    /// Reads back the offer metadata Apple stamped onto the transaction — the ground-truth check
    /// that the discount applied (`offerType` should be 2 / promotional, with our `offerID`).
    private func summary(for transaction: any InAppTransaction) -> String {
        guard let native = transaction.native as? Transaction else {
            return "Purchased. (Could not read native transaction.)"
        }
        let offerType = native.offerType.map { "\($0.rawValue)" } ?? "nil"
        let offerID = native.offerID ?? "nil"
        return """
            Purchased ✅
            transactionID: \(native.id)
            productID: \(native.productID)
            offerType: \(offerType)  (2 = promotional)
            offerID: \(offerID)
            """
    }
}
