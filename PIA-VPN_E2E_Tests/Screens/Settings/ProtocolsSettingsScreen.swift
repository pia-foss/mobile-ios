//
//  ProtocolsSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var protocolsHeader: XCUIElement{
        staticText(with: "Protocols")
    }
    
    var protocolSelectionButton: XCUIElement {
        staticText(with: "Protocol Selection")
    }
    
    var protocolSelectionPopover: XCUIElement {
        otherElement(with: "ProtocolPopoverSelectionView")
    }
    
    var dataEncryptionButton: XCUIElement {
        staticText(with: "Data Encryption")
    }
    
    var dataEncryptionPopover: XCUIElement {
        otherElement(with: "DataEncryptionPopoverSelectionView")
    }
    
    var handshakeButton: XCUIElement {
        staticText(with: "Handshake")
    }
    
    var handshakePopover: XCUIElement {
        otherElement(with: "HandshakePopoverSelectionView")
    }
    
    var transportButton: XCUIElement {
        staticText(with: "Transport")
    }
    
    var transportPopover: XCUIElement {
        otherElement(with: "TransportPopoverSelectionView")
    }
    
    var remotePortButton: XCUIElement {
        staticText(with: "Remote Port")
    }
    
    var remotePortPopover: XCUIElement {
        otherElement(with: "PortPopoverSelectionView")
    }
    
    var useSmallPacketsSwitch: XCUIElement {
        switches(with: "Use Small Packets")
    }
    
    var openVPN: XCUIElement {
        staticText(with: "OpenVPN")
    }
    
    var ipsec: XCUIElement {
        staticText(with: "IPSec (IKEv2)")
    }
    
    var wireguard: XCUIElement {
        staticText(with: "WireGuard®")
    }
    
    func navigateToProtocolSettings() {
        navigateToSettings()
        protocolsSettingsButton.waitForElementToAppear()
        protocolsSettingsButton.tap()
        XCTAssert(protocolsHeader.waitForElementToAppear())
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
