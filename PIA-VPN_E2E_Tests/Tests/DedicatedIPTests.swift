//
//  DedicatedIPTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class DedicatedIPTests: BaseTest {
    override func setUpWithError() throws {
        try super.setUpWithError()

        // A dedicated IP removed while the VPN is connected to it is listed again, so disconnect first.
        app.disconnectToVPN()
        app.navigateToDedicatedIPScreen()
        if app.dedicatedIPList.waitForExistence(timeout: app.defaultTimeout) {
            app.deleteDedicatedIP()
        }
        app.navigateToHome(using: app.closeButton)
    }

    // MARK: - Dedicated IP validation

    func testAddsValidToken() {
        app.navigateToDedicatedIPScreen()
        app.activateDedicatedIP(with: DedicatedIP.valid)
        XCTAssertTrue(app.dedicatedIPList.waitForExistence(timeout: app.defaultTimeout))
    }

    func testShowsErrorForInvalidToken() {
        app.navigateToDedicatedIPScreen()
        app.activateDedicatedIP(with: DedicatedIP.invalid)
        XCTAssertTrue(app.invalidTokenErrorMessage.waitForExistence(timeout: app.defaultTimeout))
    }

    func testShowsErrorForEmptyToken() {
        app.navigateToDedicatedIPScreen()
        app.activateDedicatedIP(with: DedicatedIP.empty)
        XCTAssertTrue(app.emptyTokenErrorMessage.waitForExistence(timeout: app.defaultTimeout))
    }

    // MARK: - Managing dedicated IP

    func testConnectsToValidDedicatedIP() throws {
        try requireRealDevice()
        app.disconnectToVPN()
        let publicIP = app.publicIPAddress()
        app.navigateToDedicatedIPScreen()
        app.activateDedicatedIP(with: DedicatedIP.valid)
        XCTAssertTrue(app.dedicatedIPList.waitForElementToAppear())
        let dipName = app.dedicatedIPName
        let dipAddress = app.dedicatedIPAddress
        app.navigateToHome(using: app.closeButton)

        app.navigateToRegionSelection()
        XCTAssertTrue(app.dedicatedIPRegion.waitForElementToAppear(), "Dedicated IP not listed in Region selection")
        app.dedicatedIPRegion.tap()
        XCTAssertTrue(app.connectedStatusLabel.waitForExistence(timeout: app.vpnConnectionTimeout))
        XCTAssertTrue(app.regionTileCollectionViewCell.staticTexts[dipName].waitForExistence(timeout: app.defaultTimeout))
        XCTAssertEqual(app.assertConnectedThroughVPN(publicIPBeforeConnecting: publicIP), dipAddress, "VPN IP isn't the dedicated IP")
    }

    func testDeletesListedDedicatedIP() {
        app.navigateToDedicatedIPScreen()
        app.activateDedicatedIP(with: DedicatedIP.valid)
        app.deleteDedicatedIP()
        XCTAssertTrue(app.dedicatedIPTextField.waitForExistence(timeout: app.defaultTimeout))
    }
}
