//
//  PIAShadow.swift
//  PIADesignSystem
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

import SwiftUI

/// A drop shadow from the PIA design system.
public struct PIAShadow: Sendable {
    /// The shadow colour, including its opacity.
    public let color: Color
    /// The SwiftUI blur radius. See the note on `card` about converting Figma blur values.
    public let radius: CGFloat
    /// Horizontal offset.
    public let x: CGFloat
    /// Vertical offset.
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension PIAShadow {
    /// Figma `drop-shadow-card`: colour `#0000001A`, offset `(0, 0)`, blur `17`.
    ///
    /// - Important: Figma's *blur* is roughly **twice** SwiftUI's shadow *radius*, so a blur of 17
    ///   becomes a radius of 8.5. Passing the Figma blur straight into `.shadow(radius:)` is a very
    ///   common mistake and produces a shadow about twice as large as designed.
    static let card = PIAShadow(color: Color(white: 0, opacity: 0.10), radius: 8.5, x: 0, y: 0)
}

public extension View {
    /// Applies a PIA design system shadow.
    ///
    /// Example:
    /// ```swift
    /// RoundedRectangle(cornerRadius: PIARadius.r12)
    ///     .fill(Color.pia.surfaceContainerPrimary)
    ///     .piaShadow()
    /// ```
    func piaShadow(_ shadow: PIAShadow = .card) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

#Preview {
    RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
        .fill(Color.pia.surfaceContainerPrimary)
        .frame(height: 64)
        .piaShadow()
        .padding(PIASpacing.s24)
        .background(Color.pia.background)
}
