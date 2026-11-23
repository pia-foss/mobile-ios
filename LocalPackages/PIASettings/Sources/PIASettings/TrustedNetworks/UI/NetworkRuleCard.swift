//
//  NetworkRuleCard.swift
//  PIASettings
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
import PIALocalizations
import SwiftUI

struct NetworkRuleCard: View {
    private static let statusStripHeight: CGFloat = 5
    private static let iconSize: CGFloat = 20
    private static let iconTileSize: CGFloat = 40

    let rule: TrustedNetworksSettings.Rule
    let width: CGFloat
    /// Square cards still grow when their content needs more room
    let isSquare: Bool
    let onSelect: (TrustedNetworksSettings.Behavior) -> Void
    let onRemove: (() -> Void)?

    var body: some View {
        Menu {
            NetworkBehaviorMenuItems(onSelect: onSelect)
            if let onRemove {
                Button(role: .destructive, action: onRemove) {
                    Text(L10n.Global.remove)
                }
            }
        } label: {
            content
        }
        .accessibilityLabel("\(rule.network.title) \(rule.behavior.title)")
        .accessibilityHint(L10n.Global.edit)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            rule.icon
                .resizable()
                .scaledToFit()
                .frame(width: Self.iconSize, height: Self.iconSize)
                .frame(width: Self.iconTileSize, height: Self.iconTileSize)
                .background(Color.pia.background)
                .cornerRadius(PIARadius.r12)
                .accessibilityHidden(true)

            Spacer(minLength: PIASpacing.s8)

            VStack(alignment: .leading, spacing: PIASpacing.s4) {
                Text(rule.network.title)
                    .typography(.title2, color: .pia.onSurface)
                Text(rule.behavior.title)
                    .typography(.body2, color: .pia.onSurfaceContainerSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, PIASpacing.s20)
        .padding(.top, PIASpacing.s20)
        .padding(.bottom, PIASpacing.s12)
        .frame(width: width, alignment: .leading)
        .frame(minHeight: isSquare ? width : nil)
        .background(Color.pia.surfaceContainerPrimary)
        .overlay(alignment: .top) {
            rule.behavior.statusColor
                .frame(height: Self.statusStripHeight)
        }
        .overlay(alignment: .topTrailing) {
            NMTAsset.iconOptions.swiftUIImage
                .renderingMode(.template)
                .foregroundColor(.pia.onSurfaceContainerSecondary)
                .accessibilityHidden(true)
                .padding(.top, PIASpacing.s20)
                .padding(.trailing, PIASpacing.s20)
        }
        .cornerRadius(PIARadius.r12)
        .contentShape(RoundedRectangle(cornerRadius: PIARadius.r12))
    }
}

#Preview {
    HStack(alignment: .top, spacing: 18) {
        NetworkRuleCard(
            rule: .init(network: .secureWiFi, behavior: .alwaysConnect),
            width: 167,
            isSquare: true,
            onSelect: { _ in },
            onRemove: nil
        )
        NetworkRuleCard(
            rule: .init(network: .custom(ssid: "Home"), behavior: .retainState),
            width: 167,
            isSquare: true,
            onSelect: { _ in },
            onRemove: {}
        )
    }
    .padding()
    .background(Color.pia.background)
}
