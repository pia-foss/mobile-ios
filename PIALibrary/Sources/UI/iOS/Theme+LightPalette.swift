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