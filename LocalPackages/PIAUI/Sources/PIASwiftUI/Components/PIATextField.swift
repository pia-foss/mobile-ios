//
//  PIATextField.swift
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

/// Outlined text field with an optional title above it.
public struct PIATextField: View {
    @FocusState private var isFocused: Bool

    private let title: String?
    private let placeholder: String
    @Binding private var text: String

    public init(_ title: String? = nil, placeholder: String, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s8) {
            if let title {
                Text(title)
                    .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                    .accessibilityHidden(true)
            }

            TextField(placeholder, text: $text)
                .typography(.body1, color: .pia.onSurface)
                .focused($isFocused)
                .padding(PIASpacing.s12)
                .modifier(TextFieldModifier(isFocused: isFocused, focusedOutline: .pia.primary))
                .accessibilityLabel(title ?? placeholder)
        }
    }
}

#Preview {
    VStack(spacing: PIASpacing.s16) {
        PIATextField("Primary DNS", placeholder: "Required", text: .constant("1.1.1.1"))
        PIATextField("Secondary DNS", placeholder: "Optional", text: .constant(""))
        PIATextField(placeholder: "No title", text: .constant(""))
    }
    .padding()
    .background(Color.pia.background)
}
