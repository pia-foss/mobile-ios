//
//  PIA_VPN_tvOS_E2E_TestsLaunchTests.swift
//  PIA VPN-tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

final class PIA_VPN_tvOS_E2E_TestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
