//
//  Theme+DarkPalette.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 1/23/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

extension Theme.Palette {
    static var dark: Theme.Palette {
        let lightPalette: Theme.Palette = .light
        
        let palette = Theme.Palette()
        palette.appearance = Theme.Appearance.dark
        palette.logo = Asset.navLogoWhite.image
        palette.brandBackground = lightPalette.brandBackground
        palette.lightBackground = .piaGrey6
        palette.lineColor = .white
        palette.solidLightBackground = Macros.color(hex: 0x232323, alpha: 0xff)
        palette.emphasis = lightPalette.emphasis
        palette.accent1 = lightPalette.accent1
        palette.accent2 = lightPalette.accent2
        palette.setDarkText(.white, alphas: [1.0, 0.87, 0.67])
        palette.setLightText(.white, alphas: [1.0, 0.87, 0.67])
        palette.divider = UIColor(white: 1.0, alpha: 0.2)
        palette.overlayAlpha = 0.9
        return palette
    }
}
