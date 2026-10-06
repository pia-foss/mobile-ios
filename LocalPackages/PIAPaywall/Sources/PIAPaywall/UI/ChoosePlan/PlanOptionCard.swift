//
//  PlanOptionCard.swift
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
import PIASwiftUI
import SwiftUI

/// One selectable plan inside the "Choose your plan" sheet.
struct PlanOptionCard: View {
    let title: String
    let price: String
    let billingDetail: String
    let savings: String?
    let footer: String
    let hasTrial: Bool
    let isSelected: Bool
    let action: () -> Void

    private enum Metrics {
        static let radioSize: CGFloat = 24
        static let radioPadding: CGFloat = 12
        static let checkSize: CGFloat = 14
        static let giftSize: CGFloat = 20
        static let selectedBorderWidth: CGFloat = 2
        static let borderWidth: CGFloat = 1
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: PIASpacing.s16) {
                HStack(alignment: .center, spacing: PIASpacing.s16) {
                    radio
                    details
                    Spacer(minLength: 0)
                }
                footerView
            }
            .padding(PIASpacing.s12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
                    .fill(Color.pia.surfaceContainerPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.pia.primary : Color.pia.outlineVariantPrimary,
                        lineWidth: isSelected ? Metrics.selectedBorderWidth : Metrics.borderWidth
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Announced as one radio option rather than separate labels.
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var radio: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.pia.primary)
                Asset.Piax.Global.iconCheck.swiftUIImage
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Metrics.checkSize, height: Metrics.checkSize)
                    .foregroundColor(.pia.onPrimary)
            } else {
                Circle()
                    .strokeBorder(Color.pia.outlineVariantPrimary, lineWidth: Metrics.borderWidth)
            }
        }
        .frame(width: Metrics.radioSize, height: Metrics.radioSize)
        .padding(Metrics.radioPadding)
        .accessibilityHidden(true)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s8) {
            Text(title)
                .typography(.body2, color: .pia.onSurfaceContainerPrimary)

            VStack(alignment: .leading, spacing: PIASpacing.s4) {
                HStack(alignment: .center, spacing: PIASpacing.s8) {
                    Text(price)
                        .typography(.subtitle1, color: .pia.onSurface)
                    if let savings {
                        savingsTag(savings)
                    }
                }
                Text(billingDetail)
                    .typography(.body2, color: .pia.onSurfaceContainerPrimary)
            }
        }
    }

    private func savingsTag(_ text: String) -> some View {
        Text(text)
            .bold()
            .typography(.caption1, color: .pia.onSuccessContainer)
            .padding(.horizontal, PIASpacing.s8)
            .padding(.vertical, PIASpacing.s4)
            .background(Capsule().fill(Color.pia.successContainer))
            .fixedSize()
    }

    private var footerView: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s8) {
            Rectangle()
                .fill(Color.pia.outline)
                .frame(height: Metrics.borderWidth)

            HStack(alignment: .center, spacing: PIASpacing.s4) {
                if hasTrial {
                    Asset.iconPaywallGift.swiftUIImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Metrics.giftSize, height: Metrics.giftSize)
                        .foregroundColor(.pia.primary)
                        .accessibilityHidden(true)
                }
                Text(footer)
                    .typography(.body2, color: hasTrial ? Color.pia.primary : Color.pia.onSurfaceContainerPrimary)
            }
            .padding(.vertical, PIASpacing.s4)
        }
    }
}

#Preview {
    VStack(spacing: PIASpacing.s12) {
        PlanOptionCard(
            title: "Yearly",
            price: "$4.00/month",
            billingDetail: "$47.99 billed once a year",
            savings: "Save 67%",
            footer: "Try FREE for 7 Days",
            hasTrial: true,
            isSelected: true,
            action: {}
        )

        PlanOptionCard(
            title: "Monthly",
            price: "$11.99/month",
            billingDetail: "Billed monthly",
            savings: nil,
            footer: "No free trial on this plan",
            hasTrial: false,
            isSelected: false,
            action: {}
        )
    }
    .padding(PIASpacing.s24)
    .background(Color.pia.background)
}
