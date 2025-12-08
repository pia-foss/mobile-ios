//
//  Fonts.swift
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

/// SF Pro font extensions for PIA VPN design system.
///
/// Provides SF Pro font variants (Bold, Semibold, Regular) at custom sizes.
///
/// Example:
/// ```swift
/// Text("Bold Text").font(.sfProBold(size: 18))
/// Text("Semibold Text").font(.sfProSemibold(size: 16))
/// Text("Regular Text").font(.sfProRegular(size: 14))
/// ```
@available(iOS 13.0, *)
extension Font {
    /// SF Pro Bold font
    ///
    /// - Parameter size: The font size in points
    /// - Returns: SF Pro Bold font at the specified size
    static func sfProBold(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    /// SF Pro Semibold font
    ///
    /// - Parameter size: The font size in points
    /// - Returns: SF Pro Semibold font at the specified size
    static func sfProSemibold(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }

    /// SF Pro Regular font
    ///
    /// - Parameter size: The font size in points
    /// - Returns: SF Pro Regular font at the specified size
    static func sfProRegular(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
}
