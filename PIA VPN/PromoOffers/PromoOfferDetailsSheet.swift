//
//  PromoOfferDetailsSheet.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

/// The contents of the offer's bottom sheet: what the offer is, what it costs, and the one button
/// that claims it.
///
/// Stateless by design — the presenting host owns the purchase state, so the sheet renders identically
/// in a preview and in the app.
struct PromoOfferDetailsSheet: View {
    let data: PromoOfferBannerState.BannerData
    let isPurchasing: Bool
    let errorMessage: String?
    let onClaim: () -> Void

    var body: some View {
        VStack(spacing: PIASpacing.s24) {
            // Full-bleed: the header deliberately ignores the sheet's horizontal padding.
            PromoOfferHeaderView(freeDays: data.freeDays, expiryDate: data.expiryDate)

            VStack(spacing: PIASpacing.s24) {
                summary
                callToAction
            }
            .padding(.horizontal, PIASpacing.s20)
        }
        .padding(.bottom, PIASpacing.s32)
        .frame(maxWidth: .infinity)
        .background(Color.pia.background)
    }

    private var summary: some View {
        Text(
            PromoOfferText.markdown(
                L10n.PromoOffer.Sheet.summary(
                    PromoOfferText.date(data.expiryDate),
                    data.freeDays
                )
            )
        )
        .typography(.body2, color: .pia.onBackground)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }

    private var callToAction: some View {
        VStack(spacing: PIASpacing.s12) {
            Button(action: onClaim) {
                Text(L10n.PromoOffer.Cta.claim).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary, isLoading: isPurchasing))
            .disabled(isPurchasing)

            if let errorMessage {
                Text(errorMessage)
                    .typography(.caption1, color: .pia.error)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(PromoOfferText.markdown(disclaimer))
                .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, PIASpacing.s8)
    }

    /// The price clause is dropped when the App Store did not return a price, rather than shown with
    /// a placeholder — a billing disclaimer with a hole in it is worse than a shorter one.
    private var disclaimer: String {
        let renewal = PromoOfferText.date(data.renewalDate)
        guard let price = data.renewalPrice else {
            return L10n.PromoOffer.Sheet.disclaimer(renewal)
        }
        return L10n.PromoOffer.Sheet.disclaimerWithPrice(price, renewal)
    }

}

#if DEBUG
    extension PromoOfferBannerState.BannerData {
        static var preview: Self {
            .init(
                freeDays: 60,
                expiryDate: Date(timeIntervalSince1970: 1_760_313_600),
                renewalDate: Date(timeIntervalSince1970: 1_765_497_600),
                renewalPrice: "$11.95/month",
                productIdentifier: "com.privateinternetaccess.subscription.1month",
                offerIdentifier: "autobilloff60d"
            )
        }
    }

    #Preview("Light") {
        PromoOfferDetailsSheet(data: .preview, isPurchasing: false, errorMessage: nil, onClaim: {})
            .frame(width: 375)
    }

    #Preview("Purchasing") {
        PromoOfferDetailsSheet(data: .preview, isPurchasing: true, errorMessage: nil, onClaim: {})
            .frame(width: 375)
    }

    #Preview("Error") {
        PromoOfferDetailsSheet(
            data: .preview,
            isPurchasing: false,
            errorMessage: L10n.PromoOffer.Sheet.error,
            onClaim: {}
        )
        .frame(width: 375)
    }

    #Preview("Dark") {
        PromoOfferDetailsSheet(data: .preview, isPurchasing: false, errorMessage: nil, onClaim: {})
            .frame(width: 375)
            .environment(\.colorScheme, .dark)
    }
#endif
