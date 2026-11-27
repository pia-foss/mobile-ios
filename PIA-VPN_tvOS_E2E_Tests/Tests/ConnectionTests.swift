//
//  ConnectionTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 3/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class ConnectionTests: BaseTest {
    // MARK: - Dashboard screen

    func testShowsConnectedAfterConnectingFromDisconnectedState() {
        app.connect()
        XCTAssertTrue(app.connectedStatus.waitForElementToAppear())
    }

    func testShowsNotConnectedAfterDisconnectingFromConnectedState() {
        app.connect()
        app.disconnect()
        XCTAssertTrue(app.notConnectedStatus.waitForElementToAppear())
    }

    // MARK: - Connecting to a specific location

    func testConnectsToSelectedLocation() {
        app.navigateToLocationSelectionScreen()
        app.navigateToSearchLocationScreen()
        app.connectTo(region: "Peru")
        XCTAssertTrue(app.connectedStatus.waitForElementToAppear())
        XCTAssertTrue(app.selectedLocationButton.label.contains("Peru"))
    }

    func testQuickLocationsShowPreviouslyConnectedLocations() {
        app.navigateToLocationSelectionScreen()
        app.navigateToSearchLocationScreen()
        app.connectTo(region: "Peru")
        XCTAssertTrue(app.selectedLocationButton.label.contains("Peru"))

        app.navigateToLocationSelectionScreen()
        app.navigateToSearchLocationScreen()
        app.connectTo(region: "Ohio")
        XCTAssertTrue(app.selectedLocationButton.label.contains("Ohio"))
        XCTAssertTrue(app.button(with: "PE").waitForElementToAppear())

        app.navigateToLocationSelectionScreen()
        app.navigateToSearchLocationScreen()
        app.connectTo(region: "Nepal")
        XCTAssertTrue(app.selectedLocationButton.label.contains("Nepal"))
        XCTAssertTrue(app.button(with: "US").waitForElementToAppear())
    }
}
