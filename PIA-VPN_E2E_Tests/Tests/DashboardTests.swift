//
//  DashboardTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 18/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class DashboardTests:BaseTest {
    override class func spec() {
        super.spec()
        
        describe("dashboard connection details tests") {
            context("updated connection settings") {
                it("should update the connection details on dashboard, when the user sets up IPSec (IKEv2)") {
                    app.navigateToProtocolSettings()
                    app.selectProtocol(protocolName: "IPSec (IKEv2)")
                    app.selectDataEncryption(dataEncryption: "AES-256-CBC")
                    app.selectHandshake(handshake: "SHA96")
                    app.navigateToHomeFromSettings()
                    
                    app.navigateToEditDashboardScreen()
                    expect(app.connectionTileCell.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"IPSec (IKEv2)")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"AES-256-CBC")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"SHA96")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
                
                it("should update the connection details on dashboard, when the user sets up WireGuard®") {
                    app.navigateToProtocolSettings()
                    app.selectProtocol(protocolName: "WireGuard®")
                    app.navigateToHomeFromSettings()
                    
                    app.navigateToEditDashboardScreen()
                    expect(app.connectionTileCell.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"WireGuard®")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"ChaCha20")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"Noise_IK")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
                
                it("should update the connection details on dashboard, when the user sets up OpenVPN") {
                    app.navigateToProtocolSettings()
                    app.selectProtocol(protocolName: "OpenVPN")
                    app.selectDataEncryption(dataEncryption: "AES-256-GCM")
                    app.selectTransport(transport: "TCP")
                    app.selectRemotePort(port: "443")
                    app.navigateToHomeFromSettings()
                    
                    app.navigateToEditDashboardScreen()
                    expect(app.connectionTileCell.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"OpenVPN")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"AES-256-GCM")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"TCP")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"443")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.connectionTileCell.findChildElement(matching: .staticText, identifier:"RSA-4096")?.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
            }
        }
    }
}
