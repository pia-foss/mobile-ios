//
//  UIImage+Color.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

/// Extension of the uiimage class, for simple helper methods.
public extension UIImage {
        
    /// Method to create an image from a colour
    /// - Parameter color: The colour to convert to image
    /// - Returns: The image that is a colour
    public static func fromColor(_ color: UIColor, height: CGFloat = 1.0) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage.fromColor(UIColor.clear)
    }
}
