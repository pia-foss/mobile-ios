//
//  TextFieldStyles.swift
//  PIADesignSystem
//
//  Created by Mario on 28/04/2026.
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

import SwiftUI

public struct TextFieldModifier: ViewModifier {
    private let isFocused: Bool
    private let normalOutline: Color
    private let focusedOutline: Color

    public init(
        isFocused: Bool,
        outline: Color = .pia.outline,
        focusedOutline: Color = .pia.outlineVariantPrimary
    ) {
        self.isFocused = isFocused
        self.normalOutline = outline
        self.focusedOutline = focusedOutline
    }

    private var outlineColor: Color {
        isFocused ? focusedOutline : normalOutline
    }

    private var outlineWidth: CGFloat {
        isFocused ? 2 : 1
    }

    public func body(content: Content) -> some View {
        content
            .background(Color.pia.surfaceContainerPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(outlineColor, lineWidth: outlineWidth)
                    .animation(.bouncy(duration: 0.25), value: isFocused)
            )
    }
}
