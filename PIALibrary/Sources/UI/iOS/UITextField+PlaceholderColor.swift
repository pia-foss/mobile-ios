//
//  UITextField+PlaceholderColor.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

extension UITextField {
    
    @IBInspectable public var placeholderColor: UIColor? {
        get {
            let attributed = self.attributedPlaceholder ?? NSAttributedString(string: "")
            var placeholderColor = self.textColor
            attributed.enumerateAttribute(
                NSAttributedStringKey.foregroundColor,
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
                let placeholderAttributes = [NSAttributedStringKey.foregroundColor: newColorValue]
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
            } else {
                print("## Placeholder color has not been set. You need to define the placeholder text first.")
            }
        }
    }
    
}
