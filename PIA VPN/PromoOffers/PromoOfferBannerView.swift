//
//  PromoOfferBannerView.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI
import UIKit

/// The offer's dashboard card.
///
/// The button opens the details sheet rather than starting the purchase: the renewal price and date
/// have to be shown before the user commits.
@MainActor
struct PromoOfferBannerView: View {
    /// Injected rather than read from the shared state so previews render without a backend call.
    let data: PromoOfferBannerState.BannerData?
    /// Supplied by `PromoOfferTile`, which owns the view controller the sheet is presented from.
    let onShowDetails: () -> Void
    let onDismiss: () -> Void

    /// The intended display face is Baloo Tamma 2, which the app does not ship, so this is SF Pro at
    /// the same size.
    @ScaledMetric(relativeTo: .largeTitle) private var dayCountSize: CGFloat = 38

    private enum Metrics {
        /// Wraps the sentence onto two lines.
        static let subtitleWidth: CGFloat = 173
        static let closeIconSize: CGFloat = 16
        static let arrowSize: CGFloat = 20
        /// Inset from the screen edges so the corner radius and the shadow both read.
        static let cardInset = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    }

    var body: some View {
        if let data {
            VStack(alignment: .leading, spacing: PIASpacing.s12) {
                copy(for: data)
                claimButton
            }
            .padding(PIASpacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Color.pia.surfaceContainerPrimary
                    .overlay(PromoOfferShapesBackground(placement: .bannerCard))
            }
            .overlay(alignment: .topTrailing) { dismissButton }
            .clipShape(RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous))
            .piaShadow()
            .padding(Metrics.cardInset)
        }
    }

    private func copy(for data: PromoOfferBannerState.BannerData) -> some View {
        VStack(alignment: .leading, spacing: PIASpacing.s4) {
            Text(
                PromoOfferText.markdown(
                    L10n.PromoOffer.Banner.expiry(PromoOfferText.date(data.expiryDate))
                )
            )
            .typography(.caption2, color: .pia.primary)
            .fixedSize(horizontal: false, vertical: true)

            // A shared baseline, so the two type sizes sit level.
            HStack(alignment: .lastTextBaseline, spacing: PIASpacing.s4) {
                Text(L10n.PromoOffer.Banner.days(data.freeDays))
                    .font(.system(size: dayCountSize, weight: .bold))
                    .foregroundColor(.pia.onSurface)

                Text(L10n.PromoOffer.Banner.free)
                    .typography(.subtitle1, color: .pia.onSurface)
            }
            .fixedSize(horizontal: false, vertical: true)

            Text(L10n.PromoOffer.Banner.subtitle)
                .typography(.caption1, color: .pia.onSurface)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: Metrics.subtitleWidth, alignment: .leading)
        }
        // Keeps the copy clear of the shield when the card is narrow or the text is scaled up.
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var claimButton: some View {
        Button(action: onShowDetails) {
            HStack(spacing: PIASpacing.s4) {
                Text(L10n.PromoOffer.Cta.claim).typography(.button2)

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: Metrics.arrowSize, height: Metrics.arrowSize)
            }
        }
        .buttonStyle(PIAButtonStyle(.primary, size: .compact))
        // Without this the style's own `maxWidth: .infinity` spans the whole card.
        .fixedSize(horizontal: true, vertical: false)
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.pia.outline)
                .frame(width: Metrics.closeIconSize, height: Metrics.closeIconSize)
                // 12pt around a 16pt glyph is a 40pt tap target; the 4pt outside it keeps the glyph
                // 16pt in from the card's edges.
                .padding(PIASpacing.s12)
                .contentShape(Rectangle())
        }
        // SwiftUI's default button style draws a bordered background on Mac Catalyst. `PIAButtonStyle`
        // is no help here: its `.plain` kind is a full-width text button, not an icon.
        .buttonStyle(.plain)
        .padding(PIASpacing.s4)
        .accessibilityLabel(L10n.PromoOffer.Banner.dismiss)
    }
}

extension PromoOfferBannerView {
    /// The height the banner needs at the current text size.
    ///
    /// Measured rather than hardcoded because the card grows with Dynamic Type, and the dashboard's
    /// fixed tile height would otherwise clip the button.
    static func preferredHeight(forWidth width: CGFloat, data: PromoOfferBannerState.BannerData?) -> CGFloat {
        let controller = UIHostingController(
            rootView: PromoOfferBannerView(data: data, onShowDetails: {}, onDismiss: {})
        )
        return controller.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude)).height
    }
}

#if DEBUG
    #Preview("Light") {
        PromoOfferBannerView(data: .preview, onShowDetails: {}, onDismiss: {})
            .frame(width: 375)
            .background(Color.pia.background)
    }

    #Preview("Dark") {
        PromoOfferBannerView(data: .preview, onShowDetails: {}, onDismiss: {})
            .frame(width: 375)
            .background(Color.pia.background)
            .environment(\.colorScheme, .dark)
    }
#endif
