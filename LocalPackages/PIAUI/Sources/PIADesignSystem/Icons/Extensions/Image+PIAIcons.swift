//
//  Image+PIAIcons.swift
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

/// PIA Design System icons.
///
/// Shipped as SVG with the vector representation preserved so they stay crisp at any size. Icons that
/// carry their own colour keep it, so do not apply `.renderingMode(.template)` to them.
///
/// Example:
/// ```swift
/// Image.pia.checkedShield
///     .resizable()
///     .frame(width: 54, height: 59)
/// ```
public extension Image {
    /// PIA Design System icons namespace
    enum PIA {
        /// A shield with a check mark, filled with the brand's green gradient. Natural size
        /// 53.87 × 58.6.
        public static let checkedShield = Image(.checkedShield)
    }

    /// Convenience accessor for PIA icons
    static var pia: PIA.Type { PIA.self }
}

#Preview {
    Image.pia.checkedShield
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 108)
        .padding(PIASpacing.s24)
        .background(Color.pia.surfaceContainerPrimary)
}
