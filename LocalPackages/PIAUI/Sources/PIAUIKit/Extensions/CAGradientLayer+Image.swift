//
//  CAGradientLayer+Image.swift
//  PIA VPN
//
//  Created by Said Rehouni on 8/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import UIKit

public extension CAGradientLayer {

    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }

    func createGradientImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { context in
            render(in: context.cgContext)
        }
    }
}
