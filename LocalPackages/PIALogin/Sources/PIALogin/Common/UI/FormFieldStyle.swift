//
//  FormFieldStyle.swift
//  PIALogin
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

/// The bordered text field shared by the sign-in screens, outlined in red while invalid.
struct FormFieldStyle: ViewModifier {
    static let height: CGFloat = 50

    let isFocused: Bool
    let isInvalid: Bool

    func body(content: Content) -> some View {
        content
            .typography(.body2, color: .pia.onSurface)
            .padding(.horizontal, PIASpacing.s16)
            .frame(height: Self.height)
            .modifier(
                TextFieldModifier(
                    isFocused: isFocused || isInvalid,
                    outline: .pia.outline,
                    focusedOutline: isInvalid ? .pia.error : .pia.primary
                )
            )
    }
}
