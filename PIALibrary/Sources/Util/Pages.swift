//
//  Pages.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 31/10/2018.
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

import Foundation

/// The sub-pages offered in the `PIAWelcomeViewController` user interface.
public struct Pages: OptionSet {
    
    /// The login page.
    public static let login = Pages(rawValue: 1 << 0)
    
    /// The purchase plan page.
    public static let purchase = Pages(rawValue: 1 << 1)
    
    /// The direct purchase plan page.
    public static let directPurchase = Pages(rawValue: 1 << 2)
    
    /// The restore page.
    public static let restore = Pages(rawValue: 1 << 3)

    /// All pages.
    public static let all: Pages = [.login, .purchase, .directPurchase, .restore]
    
    /// :nodoc:
    public let rawValue: Int
    
    /// :nodoc:
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
    
