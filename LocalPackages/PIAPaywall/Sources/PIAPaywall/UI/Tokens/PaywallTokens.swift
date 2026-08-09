//
//  PaywallTokens.swift
//  PIAPaywall
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import PIADesignSystem
import SwiftUI

/// Where this feature's Figma tokens land in `PIADesignSystem`.
///
/// Written down in one place so the mapping is auditable and a design-system rename breaks in
/// exactly one file rather than across a dozen views.
enum PaywallColor {
    /// Figma `Custom/timeline-ft-active` #037900 — `Fixed/OnSuccessContainer`. Fixed in both modes,
    /// so deliberately *not* `.pia.primary`, which turns #5DDF5A in dark.
    static let timelineActive = Color.pia.onSuccessContainer

    /// Figma `Custom/timeline-ft-inactive` #88E47B — `Fixed/OnSuccessOutline`.
    static let timelineInactive = Color.pia.onSuccessOutline

    /// Figma `Custom/on-timeline-inactive` #FFFFFF. Fixed white by design, not a semantic token.
    static let onTimelineNode = Color.white

    /// Figma `Feedback/Warning 30` #FEA754 — `Fixed/OnWarningOutline`. The "Best Value" pill.
    static let badgeBackground = Color.pia.onWarningOutline

    /// The App Store's own rating-star orange. A brand colour belonging to Apple's rating widget
    /// rather than to PIA, so it stays a literal instead of pretending to be a design token.
    static let ratingStar = Color(red: 0xFB / 255, green: 0x91 / 255, blue: 0x00 / 255)

    /// The decorative ring behind the header: white at 6%, which reads as a subtle lift in dark and
    /// is almost invisible in light — matching the design in both.
    static let backgroundRing = Color.white.opacity(0.06)
}

/// Measurements taken from the 402pt-wide Figma frame.
enum PaywallLayoutMetrics {
    /// Side margin for the trial card and the button stack.
    static let contentMargin: CGFloat = 33

    /// The benefits block. The Figma insets it to 42.5, which leaves the longest benefit exactly
    /// one point of slack — but only because every Figma text style carries `letterSpacing: -0.4`,
    /// and `PIADesignSystem` does not apply tracking (SwiftUI gained `Text.tracking` in iOS 16 and
    /// the deployment target is iOS 15). Without that tightening the line wraps, so the block is
    /// inset to the same margin as the cards below it instead.
    static let headerMargin: CGFloat = 33

    /// Keeps the single column readable when the canvas is much wider than a phone.
    static let maxContentWidth: CGFloat = 480

    /// The width the wide layout constrains its button stack to.
    static let wideMaxContentWidth: CGFloat = 560

    /// The ceiling for the whole wide layout, so a 13" iPad does not spread the benefits row and
    /// the trial card to opposite edges of the screen.
    static let wideMaxCanvasWidth: CGFloat = 900

    static let heroWidth: CGFloat = 149
    static let heroHeight: CGFloat = 120

    static let benefitIconSize: CGFloat = 20
    static let closeButtonSize: CGFloat = 24

    /// Diameter of the decorative ring, and how far its centre sits above the top edge.
    static let ringDiameter: CGFloat = 444
    static let ringLineWidth: CGFloat = 62
    static let ringCentreY: CGFloat = -68
    static let ringCentreX: CGFloat = 262
}
