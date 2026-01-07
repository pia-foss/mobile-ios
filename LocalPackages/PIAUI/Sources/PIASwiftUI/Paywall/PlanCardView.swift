//
//  PlanCardView.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 05.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
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

import SwiftUI
import PIADesignSystem

public struct PlanCardConfiguration {
    let headerText: String?
    let savingsText: String?
    let title: String
    let detail: String
    let secondaryDetail: String?

    public init(
        headerText: String?,
        savingsText: String?,
        title: String,
        detail: String,
        secondaryDetail: String?
    ) {
        self.headerText = headerText
        self.savingsText = savingsText
        self.title = title
        self.detail = detail
        self.secondaryDetail = secondaryDetail
    }
}

public struct PlanCardView: View {
    let configuration: PlanCardConfiguration
    var isSelected: Bool
    let onTap: () -> Void

    private var headerTitleColor: Color {
        isSelected ? .pia.onPrimary : .pia.onSurface
    }

    private var backgroundColor: Color {
        isSelected ? .pia.primary : .pia.surfaceContainerSecondary
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                if let headerText = configuration.headerText {
                    HStack {
                        Text(headerText)
                            .typography(.subtitle3, color: headerTitleColor)

                        Spacer()

                        // Discount tag
                        if let savingsText = configuration.savingsText {
                            Text(savingsText)
                                .typography(.subtitle3, color: .pia.onSurface)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.pia.onWarningOutline)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }

                // Plan details
                HStack(spacing: 12) {
                    // Radio Button
                    ZStack {
                        Circle()
                            .stroke(isSelected ? .pia.primary : Color.pia.outlineVariantPrimary, lineWidth: 2)
                            .frame(width: 24, height: 24)

                        if isSelected {
                            Circle()
                                .fill(Color.pia.primary)
                                .frame(width: 24, height: 24)

                            SwiftUI.Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.pia.onPrimary)
                        }
                    }

                    // Plan Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(configuration.title)
                            .typography(.body2, color: .pia.onSurfaceContainerPrimary)

                        HStack(spacing: 8) {
                            Text(configuration.detail)
                                .typography(.subtitle1, color: .pia.onSurface)

                            if let secondaryDetail = configuration.secondaryDetail {
                                Text(secondaryDetail)
                                    .typography(.body2, color: .pia.onSurfaceContainerPrimary)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.pia.surfaceContainerPrimary)
                .cornerRadius(10)
                .padding(isSelected ? 2 : 0)
                .overlay {
                    if (configuration.headerText != nil && !isSelected) || configuration.headerText == nil {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.pia.outlineVariantPrimary, lineWidth: 1)
                    }
                }
            }
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay {
                if (configuration.headerText != nil && !isSelected) || configuration.headerText == nil {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.pia.outlineVariantPrimary, lineWidth: 1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    public init(
        configuration: PlanCardConfiguration,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.isSelected = isSelected
        self.onTap = onTap
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selected: Int = 0

    VStack(spacing: 16) {
        let yearlyConfig = PlanCardConfiguration(
            headerText: "Get 3-Day Free Trial",
            savingsText: "Save 68%",
            title: "Yearly Plan",
            detail: "$90.90/year",
            secondaryDetail: "$10.08/week"
        )

        PlanCardView(
            configuration: yearlyConfig,
            isSelected: selected == 0,
            onTap: { selected = 0 }
        )

        let monthlyConfig = PlanCardConfiguration(
            headerText: "Get 3-Day Free Trial",
            savingsText: "Save 50%",
            title: "Monthly Plan",
            detail: "$30.98/month",
            secondaryDetail: "$6.08/week"
        )

        PlanCardView(
            configuration: monthlyConfig,
            isSelected: selected == 1,
            onTap: { selected = 1 }
        )

        let weeklyConfig = PlanCardConfiguration(
            headerText: nil,
            savingsText: nil,
            title: "Weekly Plan",
            detail: "$16.99/week",
            secondaryDetail: nil
        )

        PlanCardView(
            configuration: weeklyConfig,
            isSelected: selected == 2,
            onTap: { selected = 2 }
        )
    }
    .padding()
}
