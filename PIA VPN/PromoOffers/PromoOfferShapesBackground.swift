//
//  PromoOfferShapesBackground.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import PIADesignSystem
import SwiftUI

/// The offer's decorative artwork: outlined shapes filled with the brand green as it fades out to the
/// right.
///
/// Drawn rather than shipped as artwork so it stays crisp at any size with nothing to keep in sync.
/// The shield is an icon rather than decoration, so it comes from the design system instead.
struct PromoOfferShapesBackground: View {
    enum Placement {
        case sheetHeader
        case bannerCard
    }

    let placement: Placement

    /// Not one of the semantic colour tokens, and deliberately the same in both colour schemes.
    private static let brandGreen = Color(red: 0x56 / 255, green: 0xB1 / 255, blue: 0x4D / 255)

    var body: some View {
        Group {
            switch placement {
            case .sheetHeader: sheetHeaderShapes
            case .bannerCard: bannerCardShapes
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: Sheet header

    /// `solidUntil` is how far across the ring's box the gradient holds before it starts to fade.
    private struct Ring {
        let origin: CGPoint
        let solidUntil: CGFloat
    }

    private enum Circles {
        /// The width the measurements below were taken at; everything scales from it.
        static let referenceWidth: CGFloat = 375
        static let diameter: CGFloat = 375
        /// `(375 - 269.72) / 2`, the gap between the outer and inner circles.
        static let lineWidth: CGFloat = 52.64
        /// A 20% layer opacity over a 50% fill.
        static let opacity: CGFloat = 0.2 * 0.5

        static let rings = [
            Ring(origin: CGPoint(x: -190, y: 90), solidUntil: 0.418269),
            Ring(origin: CGPoint(x: 130, y: -230), solidUntil: 0)
        ]
    }

    /// Scaled by the container's width so the rings hold their position at any size.
    private var sheetHeaderShapes: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / Circles.referenceWidth

            ZStack(alignment: .topLeading) {
                ForEach(Array(Circles.rings.enumerated()), id: \.offset) { _, ring in
                    let diameter = Circles.diameter * scale

                    Circle()
                        .strokeBorder(
                            Self.gradient(solidUntil: ring.solidUntil, opacity: Circles.opacity),
                            lineWidth: Circles.lineWidth * scale
                        )
                        .frame(width: diameter, height: diameter)
                        .offset(x: ring.origin.x * scale, y: ring.origin.y * scale)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .clipped()
    }

    // MARK: Banner card

    private enum Stadium {
        static let size = CGSize(width: 334.926, height: 191.604)
        /// `(191.604 - 119.544) / 2`, the gap between the outer and inner capsules.
        static let lineWidth: CGFloat = 36.03
        static let opacity: CGFloat = 0.05

        /// How far the shape's trailing edge runs past the card's.
        ///
        /// Anchored to that edge rather than to the card's centre, so the shield stays a constant
        /// 12.7pt inside it however wide the card is.
        static let overhang: CGFloat = 202.92
        static let verticalOffset: CGFloat = 0.8

        static let shieldSize = CGSize(width: 53.8672, height: 58.6035)
        /// The shield's centre relative to the capsule's centre.
        static let shieldOffset = CGSize(width: -75.062, height: 2.601)
    }

    private var bannerCardShapes: some View {
        ZStack {
            Capsule(style: .circular)
                .strokeBorder(
                    Self.gradient(solidUntil: 0, opacity: Stadium.opacity),
                    lineWidth: Stadium.lineWidth
                )

            Image.pia.checkedShield
                .resizable()
                .frame(width: Stadium.shieldSize.width, height: Stadium.shieldSize.height)
                .offset(x: Stadium.shieldOffset.width, y: Stadium.shieldOffset.height)
        }
        .frame(width: Stadium.size.width, height: Stadium.size.height)
        .offset(x: Stadium.overhang, y: Stadium.verticalOffset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .clipped()
    }

    // MARK: Shared

    private static func gradient(solidUntil: CGFloat, opacity: CGFloat) -> LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: brandGreen.opacity(opacity), location: solidUntil),
                Gradient.Stop(color: brandGreen.opacity(0), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview("Sheet header") {
    PromoOfferShapesBackground(placement: .sheetHeader)
        .frame(width: 375, height: 167)
        .background(Color.pia.surfaceContainerPrimary)
}

#Preview("Banner card") {
    PromoOfferShapesBackground(placement: .bannerCard)
        .frame(width: 335, height: 178)
        .background(Color.pia.surfaceContainerPrimary)
}
