//
//  PaywallDisclaimerView.swift
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

/// The billing terms: an emphasised sentence carrying the price, then the detail.
///
/// Renders redacted while prices are still loading, so the screen never quotes a figure it does not
/// yet know.
struct PaywallDisclaimerView: View {
    let disclaimer: PaywallDisclaimer?

    var body: some View {
        VStack(spacing: PIASpacing.s4) {
            if let disclaimer {
                Text(disclaimer.headline)
                    .typography(.subtitle3, color: .pia.onSurface)
                Text(disclaimer.detail)
                    .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
            } else {
                // Placeholder lines of roughly the real length, so the layout does not jump when
                // the prices arrive.
                Text(String(repeating: " ", count: 44))
                    .typography(.subtitle3, color: .pia.onSurface)
                Text(String(repeating: " ", count: 90))
                    .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .redacted(reason: disclaimer == nil ? .placeholder : [])
    }
}

#Preview("Priced") {
    PaywallDisclaimerView(
        disclaimer: PaywallDisclaimer(
            headline: "7 days free, then $72.98 per year.",
            detail: "Renews automatically unless cancelled at least 24 hours before the period ends."
        )
    )
    .padding(PIASpacing.s24)
    .background(Color.pia.background)
}

/// Prices have not arrived: two redacted placeholder lines of roughly the real length.
#Preview("Loading") {
    PaywallDisclaimerView(disclaimer: nil)
        .padding(PIASpacing.s24)
        .background(Color.pia.background)
}
