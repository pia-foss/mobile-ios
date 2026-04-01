//
//  ProtocolsSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var protocolsHeader: XCUIElement {staticText(with: protocolsTitleString)}
    var protocolsSelectionButtonString: String {getString(key: "settings.connection.vpn_protocol.title", comment: "Protocol Selection")}
    var protocolSelectionButton: XCUIElement {staticText(with: protocolsSelectionButtonString)}
    var protocolSelectionPopover: XCUIElement {otherElement(with: "ProtocolPopoverSelectionView")}
    var dataEncryptionButtonString: String {getString(key: "settings.encryption.cipher.title", comment: "Data Encryption")}
    var dataEncryptionButton: XCUIElement {staticText(with: dataEncryptionButtonString)}
    var dataEncryptionPopover: XCUIElement {otherElement(with: "DataEncryptionPopoverSelectionView")}
    var handshakeButtonString: String {getString(key: "settings.encryption.handshake.title", comment: "Handshake")}
    var handshakeButton: XCUIElement {staticText(with: handshakeButtonString)}
    var handshakePopover: XCUIElement {otherElement(with: "HandshakePopoverSelectionView")}
    var transportButtonString: String {getString(key: "settings.connection.transport.title", comment: "Transport")}
    var transportButton: XCUIElement {staticText(with: transportButtonString)}
    var transportPopover: XCUIElement {otherElement(with: "TransportPopoverSelectionView")}
    var remotePortButtonString: String {getString(key: "settings.connection.remote_port.title", comment: "Remote Port")}
    var remotePortButton: XCUIElement {staticText(with: remotePortButtonString)}
    var remotePortPopover: XCUIElement {otherElement(with: "PortPopoverSelectionView")}
    var  useSmallPacketsString: String {getString(key: "settings.small.packets.title", comment: "Use Small Packets")}
    var useSmallPacketsSwitch: XCUIElement {switches(with: useSmallPacketsString)}
    var openVPN: XCUIElement {staticText(with: "OpenVPN")}
    var ipsec: XCUIElement {staticText(with: "IPSec (IKEv2)")}
    var wireguard: XCUIElement {staticText(with: "WireGuard®")}
    
    func navigateToProtocolSettings() {
        navigateToSettings()
        protocolsSettingsButton.waitForElementToAppear()
        protocolsSettingsButton.tap()
        XCTAssertTrue(protocolsHeader.waitForElementToAppear())
    }
    
    func selectProtocol(protocolName: String) {
        protocolSelectionButton.waitForElementToAppear()
        protocolSelectionButton.tap()
        protocolSelectionPopover.waitForElementToAppear()
        protocolSelectionPopover.staticTexts[protocolName].tap()
        protocolSelectionPopover.waitForElementToBeHidden()
    }
    
    func selectDataEncryption(dataEncryption: String) {
        dataEncryptionButton.tap()
        dataEncryptionPopover.waitForElementToAppear()
        dataEncryptionPopover.staticTexts[dataEncryption].tap()
        dataEncryptionPopover.waitForElementToBeHidden()
    }
    
    func selectHandshake(handshake: String) {
        handshakeButton.tap()
        handshakePopover.waitForElementToAppear()
        handshakePopover.staticTexts[handshake].tap()
        handshakePopover.waitForElementToBeHidden()
    }
  
    func selectTransport(transport: String) {
        transportButton.tap()
        transportPopover.waitForElementToAppear()
        transportPopover.staticTexts[transport].tap()
        transportPopover.waitForElementToBeHidden()
    }
    
    func selectRemotePort(port: String) {
        remotePortButton.tap()
        remotePortPopover.waitForElementToAppear()
        remotePortPopover.staticTexts[port].tap()
        remotePortPopover.waitForElementToBeHidden()
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
