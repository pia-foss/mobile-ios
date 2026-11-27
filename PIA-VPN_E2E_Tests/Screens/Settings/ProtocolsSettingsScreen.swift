//
//  ProtocolsSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var protocolsHeader: XCUIElement { staticText(with: protocolsTitleString) }
    var protocolsSelectionButtonString: String { getString(key: "settings.connection.vpn_protocol.title", comment: "Protocol Selection") }
    var protocolSelectionButton: XCUIElement { button(with: protocolsSelectionButtonString) }
    var dataEncryptionButtonString: String { getString(key: "settings.encryption.cipher.title", comment: "Data Encryption") }
    var dataEncryptionButton: XCUIElement { button(with: dataEncryptionButtonString) }
    var handshakeButtonString: String { getString(key: "settings.encryption.handshake.title", comment: "Handshake") }
    var handshakeButton: XCUIElement { staticText(with: handshakeButtonString) }
    var handshakePopover: XCUIElement { otherElement(with: "HandshakePopoverSelectionView") }
    var transportButtonString: String { getString(key: "settings.connection.transport.title", comment: "Transport") }
    var transportButton: XCUIElement { button(with: transportButtonString) }
    var remotePortButtonString: String { getString(key: "settings.connection.remote_port.title", comment: "Remote Port") }
    var remotePortButton: XCUIElement { button(with: remotePortButtonString) }
    var useSmallPacketsString: String { getString(key: "settings.small.packets.title", comment: "Use Small Packets") }
    var useSmallPacketsSwitch: XCUIElement { switches(with: useSmallPacketsString) }
    var openVPN: XCUIElement { selectedProtocol(VPNProtocolName.openVPN) }
    var automaticProtocol: XCUIElement { selectedProtocol(automaticString) }
    var wireguard: XCUIElement { staticText(with: VPNProtocolName.wireGuard) }

    func navigateToProtocolSettings() {
        navigateToSettings()
        XCTAssertTrue(protocolsSettingsButton.waitForElementToAppear(), "Protocols settings button not found")
        protocolsSettingsButton.tap()
        XCTAssertTrue(protocolsHeader.waitForElementToAppear())
    }

    func selectProtocol(protocolName: String) {
        XCTAssertTrue(protocolSelectionButton.waitForElementToAppear(), "Protocol selection button not found")
        selectMenuOption(protocolName, in: protocolSelectionButton)
    }

    func selectDataEncryption(dataEncryption: String) {
        selectMenuOption(dataEncryption, in: dataEncryptionButton)
    }

    func selectHandshake(handshake: String) {
        handshakeButton.tap()
        XCTAssertTrue(handshakePopover.waitForElementToAppear(), "Handshake popover not found")
        handshakePopover.staticTexts[handshake].tap()
        XCTAssertTrue(handshakePopover.waitForElementToBeHidden(), "Handshake popover still showing")
    }

    func selectTransport(transport: String) {
        selectMenuOption(transport, in: transportButton)
    }

    func selectRemotePort(port: String) {
        selectMenuOption(port, in: remotePortButton)
    }

    private func selectMenuOption(_ option: String, in menuButton: XCUIElement) {
        XCTAssertTrue(menuButton.waitForElementToAppear(), "\(option) menu not found")
        menuButton.tapTrailingControl()
        let optionButton = buttons[option]
        XCTAssertTrue(optionButton.waitForElementToAppear(), "\(option) option not found")
        optionButton.tap()
        XCTAssertTrue(optionButton.waitForElementToBeHidden(), "\(option) menu still showing")
    }

    private func selectedProtocol(_ protocolName: String) -> XCUIElement {
        buttons.matching(NSPredicate(format: "label == %@ AND value == %@", protocolsSelectionButtonString, protocolName)).firstMatch
    }

    func enableSmallPackets() {
        if ((useSmallPacketsSwitch.value as! String) == "1") {
            return
        }
        useSmallPacketsSwitch.tapTrailingControl()
    }

    func disableSmallPackets() {
        if ((useSmallPacketsSwitch.value as! String) == "0") {
            return
        }
        useSmallPacketsSwitch.tapTrailingControl()
    }
}

/// The protocols' product names, which the app shows untranslated in every language.
enum VPNProtocolName {
    static let openVPN = "OpenVPN"
    static let wireGuard = "WireGuard®"
}
