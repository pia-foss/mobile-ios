//
//  Theme+LightPalette.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 1/23/18.
//  Copyright © 2020 Private Internet Access, Inc.
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

import Foundation
import UIKit

extension Theme.Palette {

    /// Light theme.
    public static var light: Theme.Palette {
        let palette = Theme.Palette()
        palette.appearance = Theme.Appearance.light
        palette.logo = Asset.navLogo.image
        palette.secondaryColor = .white
        palette.textfieldButtonBackgroundColor = .white
        palette.navigationBarBackIcon = Asset.iconBack.image
        palette.brandBackground = Macros.color(hex: 0x009a18, alpha: 0xff)
        palette.secondaryBackground = .white
        palette.principalBackground = .piaGrey1
        palette.lineColor = .piaGreenDark20
        palette.emphasis = Macros.color(hex: 0x29cc41, alpha: 0xff)
        palette.accent1 = UIColor.piaOrange
        palette.accent2 = Macros.color(hex: 0xe60924, alpha: 0xff)
        palette.divider = UIColor(white: 0.0, alpha: 0.2)
        palette.overlayAlpha = 0.3
        return palette
    }
}
