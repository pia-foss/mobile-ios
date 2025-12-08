//
//  Text+Typography.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 08.12.25.
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

// MARK: - Typography Extension

/// Typography modifier extensions for PIA VPN design system.
///
/// Provides a convenient `.typography()` modifier for applying typography styles to Text views.
/// This modifier applies both font and line height specifications.
///
/// Example:
/// ```swift
/// Text("Main Header").typography(.title1)
/// Text("Section Header").typography(.title2, color: .primary)
/// Text("Card Title").typography(.title3, color: .white)
/// ```
@available(iOS 13.0, *)
public extension Text {
    /// Applies a typography style to the text, including font, line height, decorations, and optional color.
    ///
    /// - Parameters:
    ///   - style: The typography style to apply
    ///   - color: Optional color to apply to the text. If nil, no color is applied.
    /// - Returns: A modified Text view with the typography style applied
    func typography(_ style: TypographyStyle, color: Color? = nil) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .modifier(ConditionalUnderline(enabled: style.hasUnderline))
            .modifier(ConditionalColor(color: color))
    }
}

// MARK: - Helper ViewModifiers

/// Conditionally applies underline decoration
@available(iOS 13.0, *)
private struct ConditionalUnderline: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled, #available(iOS 16.0, *) {
            content.underline()
        } else {
            content
        }
    }
}

/// Conditionally applies foreground color
@available(iOS 13.0, *)
private struct ConditionalColor: ViewModifier {
    let color: Color?

    func body(content: Content) -> some View {
        if let color = color {
            content.foregroundColor(color)
        } else {
            content
        }
    }
}
