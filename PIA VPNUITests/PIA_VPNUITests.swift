//
//  PIA_VPNUITests.swift
//  PIA VPNUITests
//
//  Created by Davide De Rosa on 4/5/16.
//  Copyright © 2016 London Trust Media. All rights reserved.
//

import XCTest

class PIA_VPNUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

//        let app = XCUIApplication()
//        app.buttons.staticTexts
    }
    
    func testScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        let isPad = (UI_USER_INTERFACE_IDIOM() == .pad)
        let exists = NSPredicate(format: "exists == 1")
        
//        expectation(for: exists, evaluatedWith: app.buttons["uitests.login.plans.monthly"], handler: nil)
//        expectation(for: exists, evaluatedWith: app.buttons["uitests.login.plans.yearly"], handler: nil)
//        waitForExpectations(timeout: 60.0, handler: nil)

        let textUsername = app.textFields.element(boundBy: 0)
        let textPassword = app.secureTextFields.element(boundBy: 0)
        expectation(for: exists, evaluatedWith: textUsername, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)

        snapshot("0-LandingScreen")

        textUsername.tap()
        textUsername.typeText("p0000000")
        textPassword.tap()
        textPassword.typeText("foobarbogus")

        let buttonLogin = app.buttons["uitests.login.submit"]
        buttonLogin.tap()
        let buttonRegion = (isPad ? app.buttons : app.cells)["uitests.main.pick_region"]
        expectation(for: exists, evaluatedWith: buttonRegion, handler: nil)
        waitForExpectations(timeout: 30.0, handler: nil)

        snapshot("1-StatusScreen")

        buttonRegion.tap()
        expectation(for: exists, evaluatedWith: app.cells["uitests.regions.region_name"], handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)

        snapshot("2-RegionPickerScreen")

        let buttonClose = app.navigationBars.buttons.element(boundBy: 0)
        buttonClose.tap()
        let buttonMenu = app.navigationBars.buttons.element(boundBy: 0)
        buttonMenu.tap()

//        let cellAccount = app.cells["uitests.menu.account"]
//        expectation(for: exists, evaluatedWith: cellAccount, handler: nil)
//        waitForExpectations(timeout: 2.0, handler: nil)
//        cellAccount.tap()
//
//        snapshot("3-AccountScreen")

        app.tables.element(boundBy: 0).swipeUp()
        let cellLogout = app.cells["uitests.menu.logout"]
        expectation(for: exists, evaluatedWith: cellLogout, handler: nil)
        waitForExpectations(timeout: 2.0, handler: nil)
        cellLogout.tap()

        let buttonLogout = app.alerts.buttons.element(boundBy: 1)
        buttonLogout.tap()
        expectation(for: exists, evaluatedWith: textUsername, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
