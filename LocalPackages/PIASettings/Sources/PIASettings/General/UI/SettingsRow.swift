//
//  PIASettingsRow.swift
//  PIASwiftUI
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

struct SettingsRow<Accessory: View>: View {
    private let title: String
    private let description: String?
    private let accessory: Accessory
    private let isLabelAccessibilityHidden: Bool

    init(
        _ title: String,
        description: String? = nil,
        isLabelAccessibilityHidden: Bool = false,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.description = description
        self.isLabelAccessibilityHidden = isLabelAccessibilityHidden
        self.accessory = accessory()
    }

    var body: some View {
        content
            .piaSettingsListRow()
    }

    var content: some View {
        HStack(spacing: PIASpacing.s12) {
            VStack(alignment: .leading, spacing: PIASpacing.s4) {
                Text(title)
                    .typography(.body1, color: .pia.onSurface)
                if let description {
                    Text(description)
                        .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(isLabelAccessibilityHidden)

            accessory
        }
        .padding(.horizontal, PIASpacing.s16)
        .padding(.vertical, PIASpacing.s12)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

struct SettingsToggleRow: View {
    let title: String
    var description: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        SettingsRow(title, description: description, isLabelAccessibilityHidden: true) {
            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .piaToggleStyle()
                .tint(.pia.primary)
                .accessibilityHint(description ?? "")
        }
    }
}

struct SettingsNavigationRow: View {
    let title: String
    var description: String? = nil
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRow(title, description: description) {
                HStack(spacing: PIASpacing.s8) {
                    if let value {
                        Text(value)
                            .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.pia.onSurfaceContainerSecondary)
                }
            }
            .content
        }
        .buttonStyle(SettingsRowButtonStyle())
        .piaSettingsListRow()
        .accessibilityLabel(title)
        .accessibilityValue(value ?? "")
        .accessibilityHint(description ?? "")
    }
}

private struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.pia.surfaceContainerSecondary : Color.clear)
    }
}

private extension View {
    func piaSettingsListRow() -> some View {
        listRowInsets(EdgeInsets())
            .listRowBackground(Color.pia.surfaceContainerPrimary)
    }
}
