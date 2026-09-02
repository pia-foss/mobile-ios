//
//  PromoOfferHeaderView.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import PIADesignSystem
import PIALocalizations
import SwiftUI

/// The headline block at the top of the details sheet: the offer window, the number of free days, and
/// what claiming it does.
///
/// The dashboard card is a separate layout; the two share only `PromoOfferShapesBackground`.
struct PromoOfferHeaderView: View {
    let freeDays: Int
    let expiryDate: Date

    /// The intended display face is Baloo Tamma 2, which the app does not ship, so this is SF Pro at
    /// the same size — the same font `PIADesignSystem`'s own internal `Font.sfPro` resolves to.
    @ScaledMetric(relativeTo: .largeTitle) private var headlineSize: CGFloat = 45

    private enum Metrics {
        static let grabberSize = CGSize(width: 40, height: 4)
        static let headlineLineHeight: CGFloat = 50
    }

    var body: some View {
        VStack(spacing: PIASpacing.s20) {
            grabber

            VStack(spacing: PIASpacing.s12) {
                Text(L10n.PromoOffer.Header.eyebrow(PromoOfferText.date(expiryDate)))
                    .typography(.subtitle3, color: .pia.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.PromoOffer.Header.headline(freeDays))
                    .font(.system(size: headlineSize, weight: .bold))
                    .foregroundColor(.pia.onSurface)
                    .lineSpacing(Metrics.headlineLineHeight - headlineSize)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.PromoOffer.Header.subtitle)
                    .typography(.body2, color: .pia.onSurface)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, PIASpacing.s12)
        .padding(.horizontal, PIASpacing.s24)
        .padding(.bottom, PIASpacing.s24)
        .background {
            // The rings bleed past the block on every side, so they are clipped to it rather than to
            // the sheet. They also have to sit above the fill, which a second `.background` would not.
            Color.pia.surfaceContainerPrimary
                .overlay(PromoOfferShapesBackground(placement: .sheetHeader))
        }
        .clipped()
    }

    private var grabber: some View {
        RoundedRectangle(cornerRadius: PIARadius.pill, style: .continuous)
            .fill(Color.pia.onSurfaceContainerSecondary)
            .frame(width: Metrics.grabberSize.width, height: Metrics.grabberSize.height)
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    PromoOfferHeaderView(freeDays: 60, expiryDate: .now)
        .frame(width: 375)
}

#Preview("Dark") {
    PromoOfferHeaderView(freeDays: 60, expiryDate: .now)
        .frame(width: 375)
        .environment(\.colorScheme, .dark)
}
