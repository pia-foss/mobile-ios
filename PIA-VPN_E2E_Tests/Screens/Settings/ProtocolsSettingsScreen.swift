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
    
    var handshakeButton: XCUIElement {
        staticText(with: "Handshake")
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
        guard dashboardMenuButton.exists else { return }
        dashboardMenuButton.tap()
        
        if settingsButton.waitForExistence(timeout: defaultTimeout) {
            settingsButton.tap()
        }
        
        if protocolsSettingsButton.waitForExistence(timeout: defaultTimeout) {
            protocolsSettingsButton.tap()
        }
    }
    
    func selectProtocol(protocolName: String) {
        protocolSelectionButton.tap()
        guard protocolSelectionPopover.exists else {return}
        protocolSelectionPopover.staticTexts[protocolName].tap()
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
