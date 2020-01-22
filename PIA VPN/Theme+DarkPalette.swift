//
//  Theme+DarkPalette.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 1/23/18.
//  Copyright © 2020 Private Internet Access Inc.
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
import PIALibrary

extension Theme.Palette {
    static var dark: Theme.Palette {
        let lightPalette: Theme.Palette = .light
        
        let palette = Theme.Palette()
        palette.appearance = Theme.Appearance.dark
        palette.logo = Asset.navLogoWhite.image
        palette.secondaryColor = UIColor.piaGrey10
        palette.textfieldButtonBackgroundColor = UIColor.black
        palette.navigationBarBackIcon = Asset.Piax.Global.iconBack.image
        palette.brandBackground = lightPalette.brandBackground
        palette.secondaryBackground = .piaGrey5
        palette.lineColor = .white
        palette.principalBackground = .piaGrey6
        palette.emphasis = lightPalette.emphasis
        palette.accent1 = lightPalette.accent1
        palette.accent2 = lightPalette.accent2
        palette.divider = UIColor(white: 1.0, alpha: 0.2)
        palette.overlayAlpha = 0.9
        return palette
    }
}
