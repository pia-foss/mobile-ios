//
//  GradientView.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

class GradientView: UIView {
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
}
