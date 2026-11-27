//
//  ServerConnectionTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

class ServerConnectionTests: BaseTest {
    // MARK: - Home screen after logging in

    func testDefaultsVPNServerToAutomatic() {
        app.logOut()
        app.navigateToLoginScreen()
        app.logIn(with: Credentials.valid)
        app.acceptVPNPermission()
        XCTAssertTrue(app.regionTileCollectionViewCell.staticTexts[app.automaticString].waitForExistence(timeout: app.defaultTimeout))
    }

    func testConnectsWhenTappingConnectButton() throws {
        try requireRealDevice()
        app.disconnectToVPN()
        let publicIP = app.publicIPAddress()
        app.connectToVPN()
        XCTAssertTrue(app.connectedStatusLabel.waitForExistence(timeout: app.vpnConnectionTimeout))
        app.assertConnectedThroughVPN(publicIPBeforeConnecting: publicIP)
    }

    func testDisconnectsWhenTappingDisconnectButton() throws {
        try requireRealDevice()
        app.connectToVPN()
        app.disconnectToVPN()
        XCTAssertTrue(app.disconnectedStatusLabel.waitForExistence(timeout: app.vpnConnectionTimeout))
    }

    // MARK: - Region selection list

    func testConnectsToTappedRegion() throws {
        try requireRealDevice()
        app.disconnectToVPN()
        let publicIP = app.publicIPAddress()
        app.navigateToRegionSelection()
        app.searchRegion(regionName: "Philippines").firstMatch.tap()
        XCTAssertTrue(app.connectedStatusLabel.waitForExistence(timeout: app.vpnConnectionTimeout))
        XCTAssertTrue(app.regionTileCollectionViewCell.staticTexts["Philippines"].waitForExistence(timeout: app.defaultTimeout))
        app.assertConnectedThroughVPN(publicIPBeforeConnecting: publicIP)
    }

    // MARK: - Protocol changes

    func testConnectsWithWireGuardSmallPacketsEnabled() throws {
        try requireRealDevice()
        connect(protocolName: VPNProtocolName.wireGuard, smallPackets: true)
    }

    func testConnectsWithWireGuardSmallPacketsDisabled() throws {
        try requireRealDevice()
        connect(protocolName: VPNProtocolName.wireGuard, smallPackets: false)
    }

    func testConnectsWithOpenVPNSmallPacketsEnabled() throws {
        try requireRealDevice()
        connect(protocolName: VPNProtocolName.openVPN, smallPackets: true)
    }

    func testConnectsWithOpenVPNSmallPacketsDisabled() throws {
        try requireRealDevice()
        connect(protocolName: VPNProtocolName.openVPN, smallPackets: false)
    }

    // MARK: - Helpers

    private func connect(protocolName: String, smallPackets: Bool, file: StaticString = #filePath, line: UInt = #line) {
        app.disconnectToVPN()
        let publicIP = app.publicIPAddress(file: file, line: line)
        app.navigateToProtocolSettings()
        if smallPackets {
            app.enableSmallPackets()
        } else {
            app.disableSmallPackets()
        }
        app.selectProtocol(protocolName: protocolName)
        app.navigateToHomeFromSettings()
        app.connectToVPN()
        XCTAssertTrue(app.connectedStatusLabel.waitForExistence(timeout: app.vpnConnectionTimeout), file: file, line: line)
        app.assertConnectedThroughVPN(publicIPBeforeConnecting: publicIP, file: file, line: line)
    }
}
