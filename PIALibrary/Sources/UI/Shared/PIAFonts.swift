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
}

extension UIFont {
    
    public class func regularFontWith(size: CGFloat) -> UIFont! {
        return UIFont(name: Fonts.robotoTextRegular, size: size)
    }
    
}
