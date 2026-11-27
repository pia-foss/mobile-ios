//
//  DashboardTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 18/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

class DashboardTests: BaseTest {
    // MARK: - Updated dashboard connection settings

    func testConnectionTileShowsWireGuardDetails() {
        // The tile shows the live connection while connected, and the selected settings otherwise.
        app.disconnectToVPN()
        app.navigateToProtocolSettings()
        app.selectProtocol(protocolName: VPNProtocolName.wireGuard)
        app.navigateToHomeFromSettings()

        app.navigateToEditDashboardScreen()
        XCTAssertTrue(app.scrollToElement(app.connectionTileCollectionViewCell))
        XCTAssertTrue(connectionTileText(VPNProtocolName.wireGuard))
        XCTAssertTrue(connectionTileText("ChaCha20"))
        XCTAssertTrue(connectionTileText("Noise_IK"))
    }

    func testConnectionTileShowsOpenVPNDetails() {
        // The tile shows the live connection while connected, and the selected settings otherwise.
        app.disconnectToVPN()
        app.navigateToProtocolSettings()
        app.selectProtocol(protocolName: VPNProtocolName.openVPN)
        app.selectDataEncryption(dataEncryption: "AES-256-GCM")
        app.selectTransport(transport: "TCP")
        app.selectRemotePort(port: "443")
        app.navigateToHomeFromSettings()

        app.navigateToEditDashboardScreen()
        XCTAssertTrue(app.scrollToElement(app.connectionTileCollectionViewCell))
        XCTAssertTrue(connectionTileText(VPNProtocolName.openVPN))
        XCTAssertTrue(connectionTileText("AES-256-GCM"))
        XCTAssertTrue(connectionTileText("TCP"))
        XCTAssertTrue(connectionTileText("443"))
        XCTAssertTrue(connectionTileText("RSA-4096"))
    }

    // MARK: - Dashboard reordering

    func testDisplaysEnabledSections() {
        app.navigateToEditDashboardScreen()
        app.addTile(tileName: app.subscriptionTileCollectionViewCell)
        app.navigateToHome(using: app.doneEditingButton)
        XCTAssertTrue(app.scrollToElement(app.subscriptionTileCollectionViewCell))
    }

    func testHidesDisabledSections() {
        app.navigateToEditDashboardScreen()
        app.removeTile(tileName: app.subscriptionTileCollectionViewCell)
        app.navigateToHome(using: app.doneEditingButton)
        XCTAssertFalse(app.scrollToElement(app.subscriptionTileCollectionViewCell))
    }

    func testDisplaysSectionsInUserPreferredOrder() {
        app.navigateToEditDashboardScreen()
        let quickConnect = app.quickConnectTileCollectionViewCell
        let region = app.regionTileCollectionViewCell
        // Move whichever tile is lower above the other, so the test doesn't depend on the order a previous run left.
        let quickConnectWasHigher = quickConnect.isElementHigher(than: region)
        if quickConnectWasHigher {
            app.moveTile(region, onto: quickConnect)
        } else {
            app.moveTile(quickConnect, onto: region)
        }
        app.navigateToHome(using: app.doneEditingButton)
        XCTAssertEqual(quickConnect.isElementHigher(than: region), !quickConnectWasHigher)
    }

    // MARK: - Helpers

    private func connectionTileText(_ identifier: String) -> Bool {
        app.connectionTileCollectionViewCell
            .findChildElement(matching: .staticText, identifier: identifier)?
            .waitForExistence(timeout: app.defaultTimeout) ?? false
    }
}
