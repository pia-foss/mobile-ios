import Foundation
import PIALibrary
import PIALocalizations

@MainActor
final class PromoOfferBannerState {
    static let shared = PromoOfferBannerState()
    nonisolated(unsafe) static var forceShow = false

    struct BannerData {
        let freeDays: Int
        /// When current access ends, and so the day the free days start.
        let expiryDate: Date
        /// `expiryDate` plus `freeDays`.
        let renewalDate: Date
        /// Already localized, e.g. "$11.95/month". `nil` when the App Store returned no price.
        let renewalPrice: String?
        let productIdentifier: String
        let offerIdentifier: String
    }

    private(set) var bannerData: BannerData?
    private(set) var isDismissed = false
    private(set) var isPurchasing = false
    private var hasChecked = false

    var shouldShowBanner: Bool {
        !isDismissed && bannerData != nil
    }

    /// The backend decides eligibility; there is no client-side gate on when the offer may appear.
    func checkEligibilityIfNeeded() {
        guard !hasChecked else { return }
        hasChecked = true

        Task { await loadBannerOffer() }
    }

    func claimOffer() async throws {
        guard let data = bannerData, !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        let service = PromoOffersService()
        _ = try await service.signAndPurchase(
            productIdentifier: data.productIdentifier,
            offerIdentifier: data.offerIdentifier,
            appAccountToken: UUID(),
            country: nil
        )
        isDismissed = true
        NotificationCenter.default.post(name: .PIAUpdateFixedTiles, object: nil)
    }

    func dismiss() {
        isDismissed = true
        NotificationCenter.default.post(name: .PIAUpdateFixedTiles, object: nil)
    }

    func reset() {
        isDismissed = false
        hasChecked = false
        bannerData = nil
    }

    /// Reuses the paywall's price strings so both screens phrase the billing period identically in
    /// every language.
    private func renewalPrice(for productIdentifier: String, in catalog: PromoOffersService.Catalog) -> String? {
        guard let price = catalog.rows.first(where: { $0.id == productIdentifier })?.displayPrice else {
            return nil
        }

        switch productIdentifier {
        case AppConstants.InApp.yearlyProductIdentifier:
            return L10n.Signup.Paywall.Plans.Price.yearly(price)
        case AppConstants.InApp.monthlyProductIdentifier:
            return L10n.Signup.Paywall.Plans.Price.monthly(price)
        default:
            return price
        }
    }

    private func loadBannerOffer() async {
        let service = PromoOffersService()
        do {
            let catalog = try await service.loadCatalog(country: nil)

            let allOffers = catalog.rows.flatMap { row in
                row.eligibleOffers.map { (productId: row.id, offer: $0.offer, eligible: $0.eligible) }
            }
            // `forceShow` applies only when the backend returned nothing, so a genuinely eligible
            // offer always wins over a forced one.
            var candidates = allOffers.filter { $0.eligible }
            if candidates.isEmpty, Self.forceShow {
                candidates = allOffers
            }

            let bestOffer =
                candidates
                .map { ($0.productId, $0.offer) }
                .filter { $0.1.isFree && $0.1.totalDays > 0 }
                .max { $0.1.totalDays < $1.1.totalDays }

            guard let (productId, offer) = bestOffer else {
                bannerData = nil
                return
            }

            let expiryDate = Client.providers.accountProvider.currentUser?.info?.expirationDate ?? Date()
            bannerData = BannerData(
                freeDays: offer.totalDays,
                expiryDate: expiryDate,
                renewalDate: Calendar.current.date(byAdding: .day, value: offer.totalDays, to: expiryDate)
                    ?? expiryDate,
                renewalPrice: renewalPrice(for: productId, in: catalog),
                productIdentifier: productId,
                offerIdentifier: offer.id
            )
            NotificationCenter.default.post(name: .PIAUpdateFixedTiles, object: nil)
        } catch {
            bannerData = nil
        }
    }
}
