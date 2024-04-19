//
//  Common.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    /// Sometimes a system alert to request permissions about Notifications or VPN profile installation can appear
    /// at any time when the app is running
    /// This makes not possible to contitnue with the test unless the alert is dismissed
    /// This method dismisses any system alert by pressing 'Allow' button
    /// It is adviced that we call this method from all the `setUp` method of the tests from the authentication flow
    /// For tests where we require the app to be authenticated,
    /// use the method `loginAndInstallVPNProfile(from test: XCTestCase)` from the `setUp` method of the `XCTestCase`
    func dismissAnyPermissionSystemAlert(from test: XCTestCase) {
        test.addUIInterruptionMonitor(withDescription: "Any system permission alert") { element in
            
            let allowButton = element.buttons["Allow"].firstMatch
            if element.elementType == .alert && allowButton.exists {
                allowButton.tap()
                return true
            } else {
                return false
            }
        }
    }
    
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
