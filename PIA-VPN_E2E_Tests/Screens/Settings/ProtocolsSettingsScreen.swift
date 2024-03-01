//
//  ProtocolsSettingsScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 6/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
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
        guard dashboardMenuButton.waitForExistence(timeout: defaultTimeout) else {return}
        dashboardMenuButton.tap()
        
        guard settingsButton.waitForExistence(timeout: defaultTimeout) else {return}
        settingsButton.tap()
        
        guard protocolsSettingsButton.waitForExistence(timeout: defaultTimeout) else {return}
        protocolsSettingsButton.tap()
    }
    
    func selectProtocol(protocolName: String) {
        guard protocolSelectionButton.waitForExistence(timeout: defaultTimeout) else {return}
        protocolSelectionButton.tap()
        guard protocolSelectionPopover.waitForExistence(timeout: defaultTimeout) else {return}
        protocolSelectionPopover.staticTexts[protocolName].tap()
    }
    
    func selectDataEncryption(dataEncryption: String) {
        dataEncryptionButton.tap()
        guard dataEncryptionPopover.waitForExistence(timeout: defaultTimeout) else {return}
        dataEncryptionPopover.staticTexts[dataEncryption].tap()
    }
    
    func selectHandshake(handshake: String) {
        handshakeButton.tap()
        guard handshakePopover.waitForExistence(timeout: defaultTimeout) else {return}
        handshakePopover.staticTexts[handshake].tap()
    }
  
    func selectTransport(transport: String) {
        transportButton.tap()
        guard transportPopover.waitForExistence(timeout: defaultTimeout) else {return}
        transportPopover.staticTexts[transport].tap()
    }
    
    func selectRemotePort(port: String) {
        remotePortButton.tap()
        guard remotePortPopover.waitForExistence(timeout: defaultTimeout) else {return}
        remotePortPopover.staticTexts[port].tap()
    }
    
    func enableSmallPackets() {
        if ((useSmallPacketsSwitch.value as! String) != "1") {
            useSmallPacketsSwitch.tap()
        }
    }
    
    func disableSmallPackets() {
        if ((useSmallPacketsSwitch.value as! String) != "0") {
            useSmallPacketsSwitch.tap()
        }
    }
}
