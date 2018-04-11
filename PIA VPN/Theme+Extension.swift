//
//  Theme+Extension.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 3/11/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

extension Theme {
    func applyToggle(_ toggle: PIASwitch) {
        toggle.onBackgroundColor = palette.emphasis
        toggle.indeterminateBackgroundColor = palette.accent1
        toggle.offBackgroundColor = palette.accent2
    }
}
