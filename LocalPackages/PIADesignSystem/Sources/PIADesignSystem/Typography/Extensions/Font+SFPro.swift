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
/// Provides SF Pro font variants at custom sizes and weights.
///
/// Example:
/// ```swift
/// Text("Bold Text").font(.sfPro(size: 18, weight: .bold))
/// Text("Semibold Text").font(.sfPro(size: 16, weight: .semibold))
/// Text("Regular Text").font(.sfPro(size: 14, weight: .regular))
/// ```
@available(iOS 13.0, *)
extension Font {
    /// SF Pro font
    ///
    /// - Parameter size: The font size in points
    /// - Parameter weight: The font weight
    /// - Returns: SF Pro font at the specified size and weight
    static func sfPro(size: CGFloat, weight: Weight) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}
