import Foundation
import Logging
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: PromoOfferBannerState.self)

@MainActor
final class PromoOfferBannerState {
    static let shared = PromoOfferBannerState()

    struct BannerData: Equatable {
        /// Approximate length in days. 1 month is always 30 days.
        let freeDays: Int
        /// When current access ends, and so the day the free days start.
        let expiryDate: Date
        /// `expiryDate` plus the offer's calendar length.
        let renewalDate: Date
        /// Already localized, e.g. "$11.95/month". `nil` when the App Store returned no price.
        let renewalPrice: String?
        let productIdentifier: String
        let offerIdentifier: String
    }

    /// A signed offer waiting to be purchased, together with the token it was signed for: the
    /// purchase has to send back the exact same `appAccountToken`.
    private struct Preparation {
        let signature: InAppPromotionalOfferSignature
        let appAccountToken: UUID
    }

    private typealias PreparationTask = Task<Preparation, Error>

    private let service = PromoOffersService()

    private(set) var bannerData: BannerData?
    private(set) var isDismissed = false
    private var isPurchasing = false
    private var hasChecked = false
    private var preparation: PreparationTask?

    private init() {
        // Eligibility and the account-derived dates are per session.
        NotificationCenter.default.addObserver(
            forName: .PIAAccountDidLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.reset() }
        }
    }

    var shouldShowBanner: Bool {
        !isDismissed && bannerData != nil
    }

    /// The backend decides eligibility; there is no client-side gate on when the offer may appear.
    func checkEligibilityIfNeeded() {
        guard !hasChecked else { return }
        hasChecked = true

        Task { await loadBannerOffer() }
    }

    /// Signs the offer ahead of the purchase, which the backend contract asks us to do while the
    /// offer is on screen rather than when it is claimed. Idempotent, and deliberately silent: a
    /// failure only surfaces if the user goes on to claim.
    func prepare() {
        guard let data = bannerData else { return }
        _ = preparation(for: data)
    }

    func claimOffer() async throws {
        guard let data = bannerData, !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await purchase(data)
        } catch let error as PromoOffersService.ServiceError where error.isWorthRetrying {
            // The signature may have gone stale while the sheet sat open — its nonce is single-use
            // and its timestamp time-sensitive — so sign again and make one more attempt.
            log.debug("Claim failed (\(error)); re-signing the offer and retrying once")
            try await purchase(data)
        }

        // The nonce is spent, so nothing may reuse this signature.
        preparation = nil
        isDismissed = true
        NotificationCenter.default.post(name: .PIAUpdateFixedTiles, object: nil)
    }

    func dismiss() {
        isDismissed = true
        NotificationCenter.default.post(name: .PIAUpdateFixedTiles, object: nil)
    }

    private func reset() {
        preparation?.cancel()
        preparation = nil
        bannerData = nil
        isDismissed = false
        hasChecked = false
    }

    /// Purchases with the prepared signature, waiting for the signing started at display time — or
    /// starting it now, if the sheet was never shown.
    ///
    /// Any failure discards the preparation, so a retry signs a fresh, unused signature.
    private func purchase(_ data: BannerData) async throws {
        do {
            let prepared = try await preparation(for: data).value
            try await service.purchase(
                productIdentifier: data.productIdentifier,
                signature: prepared.signature,
                appAccountToken: prepared.appAccountToken
            )
        } catch {
            preparation = nil
            throw error
        }
    }

    /// The signing already in flight for `data`, or a new one.
    private func preparation(for data: BannerData) -> PreparationTask {
        if let preparation { return preparation }

        let task = PreparationTask {
            let appAccountToken = UUID()
            let signature = try await self.service.sign(
                productIdentifier: data.productIdentifier,
                offerIdentifier: data.offerIdentifier,
                appAccountToken: appAccountToken,
                country: nil
            )
            return Preparation(signature: signature, appAccountToken: appAccountToken)
        }
        preparation = task
        return task
    }

    /// Reuses the paywall's price strings so both screens phrase the billing period identically in
    /// every language.
    private func renewalPrice(for offer: PromoOffersService.EligibleOffer) -> String? {
        guard let price = offer.displayPrice else { return nil }

        switch offer.productIdentifier {
        case AppConstants.InApp.yearlyProductIdentifier:
            return L10n.Signup.Paywall.Plans.Price.yearly(price)
        case AppConstants.InApp.monthlyProductIdentifier:
            return L10n.Signup.Paywall.Plans.Price.monthly(price)
        default:
            return price
        }
    }

    private func loadBannerOffer() async {
        do {
            let offers = try await service.eligibleOffers(country: nil)
            // The longest run of free days on offer; the banner only ever promises free days.
            let freeOffers = offers.filter { $0.offer.isFree && $0.offer.totalDays > 0 }
            guard let best = freeOffers.max(by: { $0.offer.totalDays < $1.offer.totalDays }) else {
                bannerData = nil
                return
            }

            // The Apple receipt is the source of truth; the account may be stale or not loaded yet.
            let expiryDate =
                best.subscriptionExpiration
                ?? Client.providers.accountProvider.currentUser?.info?.expirationDate
                ?? Date()
            let renewalDate = Calendar.current.date(byAdding: best.offer.periodComponents, to: expiryDate)!
            bannerData = BannerData(
                freeDays: best.offer.totalDays,
                expiryDate: expiryDate,
                renewalDate: renewalDate,
                renewalPrice: renewalPrice(for: best),
                productIdentifier: best.productIdentifier,
                offerIdentifier: best.offer.id
            )
            NotificationCenter.default.post(name: .PIAUpdateFixedTiles, object: nil)
        } catch {
            log.error("Could not load the promotional offer: \(error.localizedDescription)")
            bannerData = nil
        }
    }
}

extension PromoOffersService.ServiceError {
    /// Whether signing the offer again and purchasing again could plausibly succeed. The terminal
    /// cases are the ones where a fresh signature would change nothing.
    var isWorthRetrying: Bool {
        switch self {
        case .noReceipt, .offersDisabled, .notEligible, .productNotFound:
            return false
        case .purchase(let error):
            return error != .userCancelled && error != .purchasePending && error != .sandboxPurchase
        case .malformedSignature, .backend, .unknown:
            return true
        }
    }
}
