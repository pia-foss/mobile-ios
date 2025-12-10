//
//  PIAFonts.swift
//  PIALibrary
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
