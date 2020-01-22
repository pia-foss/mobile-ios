//
//  UITextField+PlaceholderColor.swift
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

extension UITextField {
    
    @IBInspectable public var placeholderColor: UIColor? {
        get {
            let attributed = self.attributedPlaceholder ?? NSAttributedString(string: "")
            var placeholderColor = self.textColor
            attributed.enumerateAttribute(
                NSAttributedString.Key.foregroundColor,
                in: NSRange(location: 0, length: attributed.length),
                options: []
            ) { value, _, _ in
                if let color = value as? UIColor {
                    placeholderColor = color
                }
            }
            return placeholderColor
        }
        set {
            if let placeholder = self.placeholder, let newColorValue = newValue {
                let placeholderAttributes = [NSAttributedString.Key.foregroundColor: newColorValue]
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
            } else {
                print("## Placeholder color has not been set. You need to define the placeholder text first.")
            }
        }
    }
    
}
