//
//  Theme+LightPalette.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 1/23/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
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
        palette.lightBackground = .groupTableViewBackground
        palette.lineColor = .piaGreenDark20
        palette.subtitleColor = .piaGrey8
        palette.emphasis = Macros.color(hex: 0x29cc41, alpha: 0xff)
        palette.accent1 = Macros.color(hex: 0xf7941d, alpha: 0xff)
        palette.accent2 = Macros.color(hex: 0xe60924, alpha: 0xff)
        palette.setDarkText(Macros.color(hex: 0x001b31, alpha: 0xff), alphas: [0.87, 0.67, 0.37])
        palette.setLightText(.white, alphas: [0.87, 0.67, 0.37])
        palette.divider = UIColor(white: 0.0, alpha: 0.2)
        palette.overlayAlpha = 0.3
        return palette
    }
}
