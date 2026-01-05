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
/// This modifier applies both font and line height specifications with Dynamic Type support
/// for accessibility. Fonts and line heights automatically scale based on user preferences.
///
/// Example:
/// ```swift
/// Text("Main Header").typography(.title1)
/// Text("Section Header").typography(.title2, color: .primary)
/// Text("Card Title").typography(.title3, color: .white)
/// ```
public extension Text {
    /// Applies a typography style to the text, including font, line height, decorations, and optional color.
    /// Supports Dynamic Type for accessibility - text scales automatically with user's text size preferences.
    ///
    /// - Parameters:
    ///   - style: The typography style to apply
    ///   - color: Optional color to apply to the text. If nil, no color is applied.
    /// - Returns: A modified Text view with the typography style applied and Dynamic Type support
    @MainActor
    func typography(_ style: TypographyStyle, color: Color? = nil) -> some View {
        self
            .modifier(AccessibleTypographyModifier(style: style, color: color))
    }
}

/// ViewModifier that applies typography with Dynamic Type support for accessibility
private struct AccessibleTypographyModifier: ViewModifier {
    let style: TypographyStyle
    let color: Color?

    @ScaledMetric private var lineSpacing: CGFloat

    init(style: TypographyStyle, color: Color?) {
        self.style = style
        self.color = color
        _lineSpacing = ScaledMetric(wrappedValue: style.lineSpacing)
    }

    func body(content: Content) -> some View {
        content
            .modifier(ScaledFontModifier(baseSize: style.fontSize, weight: style.fontWeight))
            .lineSpacing(lineSpacing)
            .modifier(ConditionalUnderline(enabled: style.hasUnderline))
            .modifier(ConditionalColor(color: color))
    }
}
