//
//  UIImage+Color.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
//  Copyright © 2020 Private Internet Access, Inc.
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
