//
//  BenefitsList.swift
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

import PIAAssetsMobile
import PIADesignSystem
import PIALocalizations
import SwiftUI

/// What the subscription buys, as three check-marked lines.
struct BenefitsList: View {
    let layout: PaywallLayout

    private static let benefits = [
        L10n.Signup.Paywall.Benefit.servers,
        L10n.Signup.Paywall.Benefit.speed,
        L10n.Signup.Paywall.Benefit.devices
    ]

    var body: some View {
        switch layout {
        case .compact:
            VStack(alignment: .leading, spacing: PIASpacing.s8) {
                ForEach(Self.benefits, id: \.self) { benefit in
                    BenefitRow(text: benefit, layout: .compact)
                }
            }
        case .wide:
            // Three across, each with the icon above centred text.
            HStack(alignment: .top, spacing: PIASpacing.s20) {
                ForEach(Self.benefits, id: \.self) { benefit in
                    BenefitRow(text: benefit, layout: .wide)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

private struct BenefitRow: View {
    private static let iconSize: CGFloat = 20

    let text: String
    let layout: PaywallLayout

    var body: some View {
        switch layout {
        case .compact:
            HStack(alignment: .top, spacing: PIASpacing.s12) {
                icon
                Text(text).typography(.body2, color: .pia.onSurface)
                Spacer(minLength: 0)
            }
        case .wide:
            VStack(spacing: PIASpacing.s8) {
                icon
                Text(text)
                    .typography(.body2, color: .pia.onSurface)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var icon: some View {
        Asset.Piax.Global.iconCheck.swiftUIImage
            .renderingMode(.template)
            .resizable()
            .frame(width: Self.iconSize, height: Self.iconSize)
            .foregroundColor(.pia.primary)
            .accessibilityHidden(true)
    }
}

#Preview("Compact") {
    BenefitsList(layout: .compact)
        .padding(PIASpacing.s24)
        .background(Color.pia.background)
}

#Preview("Wide") {
    BenefitsList(layout: .wide)
        .padding(PIASpacing.s24)
        .background(Color.pia.background)
}
