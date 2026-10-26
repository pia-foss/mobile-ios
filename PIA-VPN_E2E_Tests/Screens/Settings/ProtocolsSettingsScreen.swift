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
    var openVPN: XCUIElement { selectedProtocol("OpenVPN") }
    var ipsec: XCUIElement { staticText(with: "IPSec (IKEv2)") }
    var wireguard: XCUIElement { selectedProtocol("WireGuard®") }

    func navigateToProtocolSettings() {
        navigateToSettings()
        protocolsSettingsButton.waitForElementToAppear()
        protocolsSettingsButton.tap()
        XCTAssertTrue(protocolsHeader.waitForElementToAppear())
    }

    func selectProtocol(protocolName: String) {
        protocolSelectionButton.waitForElementToAppear()
        selectMenuOption(protocolName, in: protocolSelectionButton)
    }

    func selectDataEncryption(dataEncryption: String) {
        selectMenuOption(dataEncryption, in: dataEncryptionButton)
    }

    func selectHandshake(handshake: String) {
        handshakeButton.tap()
        handshakePopover.waitForElementToAppear()
        handshakePopover.staticTexts[handshake].tap()
        handshakePopover.waitForElementToBeHidden()
    }

    func selectTransport(transport: String) {
        selectMenuOption(transport, in: transportButton)
    }

    func selectRemotePort(port: String) {
        selectMenuOption(port, in: remotePortButton)
    }

    private func selectMenuOption(_ option: String, in menuButton: XCUIElement) {
        menuButton.tap()
        let optionButton = buttons[option]
        optionButton.waitForElementToAppear()
        optionButton.tap()
        optionButton.waitForElementToBeHidden()
    }

    private func selectedProtocol(_ protocolName: String) -> XCUIElement {
        buttons.matching(NSPredicate(format: "label == %@ AND value == %@", protocolsSelectionButtonString, protocolName)).firstMatch
    }

    func enableSmallPackets() {
        if ((useSmallPacketsSwitch.value as! String) == "1") {
            return
        }
        useSmallPacketsSwitch.tap()
    }

    func disableSmallPackets() {
        if ((useSmallPacketsSwitch.value as! String) == "0") {
            return
        }
        useSmallPacketsSwitch.tap()
    }
}
