//
//  UILabel+LineHeight.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

public extension UILabel {
    
    /// Add a specific height to the space between the label's lines.
    ///
    /// - Parameter lineHeight: The space between lines to apply.
    public func setLineHeight(_ lineHeight: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = lineHeight
            attributeString.addAttribute(NSAttributedStringKey.paragraphStyle,
                                         value: style,
                                         range: NSRange(location: 0,
                                                        length: text.count))
            self.attributedText = attributeString
        }
    }

}
