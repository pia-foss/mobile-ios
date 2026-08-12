//
//  PIASpacing.swift
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

import CoreGraphics

/// The PIA spacing scale.
///
/// Names mirror the Figma `Spacing/spacing-*` tokens by value rather than by t-shirt size, so a
/// spacing in a design file maps to exactly one constant here with no translation step.
///
/// Example:
/// ```swift
/// VStack(spacing: PIASpacing.s12) { ... }
///     .padding(PIASpacing.s24)
/// ```
public enum PIASpacing {
    /// Figma `Spacing/spacing-4`
    public static let s4: CGFloat = 4

    /// Figma `Spacing/spacing-8`
    public static let s8: CGFloat = 8

    /// Figma `Spacing/spacing-12`
    public static let s12: CGFloat = 12

    /// Figma `Spacing/spacing-16`
    public static let s16: CGFloat = 16

    /// Figma `Spacing/spacing-20`
    public static let s20: CGFloat = 20

    /// Figma `Spacing/spacing-24`
    public static let s24: CGFloat = 24

    /// Figma `Spacing/spacing-40`
    public static let s40: CGFloat = 40
}

/// The PIA corner radius scale.
public enum PIARadius {
    /// Figma `Radius/radius-12`. Cards, plan options and buttons.
    public static let r12: CGFloat = 12
}
