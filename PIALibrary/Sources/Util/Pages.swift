//
//  Pages.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 31/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

/// The sub-pages offered in the `PIAWelcomeViewController` user interface.
public struct Pages: OptionSet {
    
    /// The login page.
    public static let login = Pages(rawValue: 1 << 0)
    
    /// The purchase plan page.
    public static let purchase = Pages(rawValue: 1 << 1)
    
    /// The redeem page.
    public static let redeem = Pages(rawValue: 1 << 2)
    
    /// The redeem page.
    public static let restore = Pages(rawValue: 1 << 3)

    /// All pages.
    public static let all: Pages = [.login, .purchase, .redeem, .restore]
    
    /// :nodoc:
    public let rawValue: Int
    
    /// :nodoc:
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
    
