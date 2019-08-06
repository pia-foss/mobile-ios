//
//  PIAFonts.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

private enum Fonts {
    static let robotoTextRegular = "Roboto-Regular"
    static let robotoTextMedium = "Roboto-Medium"
}

extension UIFont {
    
    public class func regularFontWith(size: CGFloat) -> UIFont! {
        return UIFont(name: Fonts.robotoTextRegular, size: size)
    }
    
    public class func mediumFontWith(size: CGFloat) -> UIFont! {
        return UIFont(name: Fonts.robotoTextMedium, size: size)
    }

}
