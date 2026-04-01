//
//  Common.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    func getString(key:String, comment:String) -> String{
        let localString = NSLocalizedString(key, bundle: BaseTest.bundle, comment: comment)
        return localString
    }
}

extension XCUIElement {
    func isElementHigher(than elementB: XCUIElement) -> Bool {
        let frameA = self.frame
        let frameB = elementB.frame
        return frameA.origin.y < frameB.origin.y
    }
    
    func isElementLower(than elementB: XCUIElement) -> Bool {
        let frameA = self.frame
        let frameB = elementB.frame
        return frameA.origin.y > frameB.origin.y
    }
    
    func customSortedList(_ regionList: [String]) -> [String] {
        return regionList.sorted { (first, second) -> Bool in
        let firstRegion = first.components(separatedBy: ",")[0]
        let secondRegion = second.components(separatedBy: ",")[0]
        return firstRegion < secondRegion
        }
    }
}
