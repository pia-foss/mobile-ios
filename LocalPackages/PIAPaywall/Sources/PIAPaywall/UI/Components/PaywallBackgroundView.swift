//
//  PaywallBackgroundView.swift
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

/// The paywall's backdrop: the standard page background with a large ring bleeding off the top edge.
///
/// The ring is drawn rather than shipped as artwork — it is one primitive, and drawing keeps it crisp
/// at any size and correct in both colour schemes without an asset.
struct PaywallBackgroundView: View {
    var body: some View {
        Color.pia.background
            .overlay(alignment: .topLeading) {
                Circle()
                    .strokeBorder(
                        PaywallColor.backgroundRing,
                        lineWidth: PaywallLayoutMetrics.ringLineWidth
                    )
                    .frame(
                        width: PaywallLayoutMetrics.ringDiameter,
                        height: PaywallLayoutMetrics.ringDiameter
                    )
                    .offset(
                        x: PaywallLayoutMetrics.ringCentreX - PaywallLayoutMetrics.ringDiameter / 2,
                        y: PaywallLayoutMetrics.ringCentreY - PaywallLayoutMetrics.ringDiameter / 2
                    )
                    // The ring is decoration that runs past the top of the screen.
                    .clipped()
                    .accessibilityHidden(true)
            }
            .ignoresSafeArea()
    }
}
