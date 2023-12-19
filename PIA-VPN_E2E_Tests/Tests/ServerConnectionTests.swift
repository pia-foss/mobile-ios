//
//  ServerConnectionTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class ServerConnectionTests : BaseTest {
    override class func spec() {
        super.spec()
        
        describe("server connection tests") {
            context("when the user navigates to homescreen upon logging in") {
                it("should display the vpn server defaulted to 'Automatic'") {
                    app.logOut()
                    app.navigateToLoginScreen()
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptVPNPermission()
                    expect(app.regionTileCell.staticTexts["Automatic"].exists).to(beTrue())
                }
                
                it("should connect the user to vpn when the user taps the connect button") {
                    app.disconnectToVPN()
                    app.connectToVPN()
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                }
                
                it("should disconnect the user from vpn when the user taps button to disconnect") {
                    app.connectToVPN()
                    app.disconnectToVPN()
                    expect(app.disconnectedStatusLabel.exists).to(beTrue())
                }
            }
            
            context("when the user navigates to the regional selection list") {
                it("should connect the user to the selection region when the region is tapped") {
                    app.disconnectToVPN()
                    app.navigateToRegionSelection()
                    app.searchRegion(regionName: "Philippines").firstMatch.tap()
                    expect(app.connectedStatusLabel.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.regionTileCell.staticTexts["Philippines"].exists).to(beTrue())
                }
            }
            
            context("when the user changes protocol type") {
                it("should connect the user to vpn successfully when the user enables small packet for IPSec(IKEv2)") {
                    app.disconnectToVPN()
                    app.navigateToProtocolSettings()
                    app.enableSmallPackets()
                    app.selectProtocol(protocolName: "IPSec (IKEv2)")
                    app.navigateToHomeFromSettings()
                    app.connectToVPN()
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                }
                
                it("should connect the user to vpn successfully when the user disables small packet for IPSec(IKEv2)") {
                    app.disconnectToVPN()
                    app.navigateToProtocolSettings()
                    app.disableSmallPackets()
                    app.selectProtocol(protocolName: "IPSec (IKEv2)")
                    app.navigateToHomeFromSettings()
                    app.connectToVPN()
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                }
                
                it("should connect the user to vpn successfully when the user enables small packet for Wireguard") {
                    app.disconnectToVPN()
                    app.navigateToProtocolSettings()
                    app.enableSmallPackets()
                    app.selectProtocol(protocolName: "WireGuard®")
                    app.navigateToHomeFromSettings()
                    app.connectToVPN()
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                }
                
                it("should connect the user to vpn successfully when the user disables small packet for Wireguard") {
                    app.disconnectToVPN()
                    app.navigateToProtocolSettings()
                    app.disableSmallPackets()
                    app.selectProtocol(protocolName: "WireGuard®")
                    app.navigateToHomeFromSettings()
                    app.connectToVPN()
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                }
                
                it("should connect the user to vpn successfully when the user enables small packet for OpenVPN") {
                    app.disconnectToVPN()
                    app.navigateToProtocolSettings()
                    app.enableSmallPackets()
                    app.selectProtocol(protocolName: "OpenVPN")
                    app.navigateToHomeFromSettings()
                    app.connectToVPN()
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                }
                
                it("should connect the user to vpn successfully when the user disables small packet for OpenVPN") {
                    app.disconnectToVPN()
                    app.navigateToProtocolSettings()
                    app.disableSmallPackets()
                    app.selectProtocol(protocolName: "OpenVPN")
                    app.navigateToHomeFromSettings()
                    app.connectToVPN()
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                }
            }
        }
    }
}
