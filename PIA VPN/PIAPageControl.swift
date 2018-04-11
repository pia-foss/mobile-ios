//
//  PIAPageControl.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import FXPageControl

class PIAPageControl: FXPageControl {
    override func draw(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()?.clear(rect)
        super.draw(rect)
    }
}

//extension FXPageControl {
//    open override func draw(_ rect: CGRect) {
//        UIGraphicsGetCurrentContext()?.clear(rect)
//        super.draw(rect)
//    }
//}
