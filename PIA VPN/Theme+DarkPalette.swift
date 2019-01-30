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
