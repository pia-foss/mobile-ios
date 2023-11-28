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
                    expect(app.vpnServerButton.staticTexts["Automatic"].exists).to(beTrue())
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
                    expect(app.connectedStatusLabel.exists).to(beTrue())
                    expect(app.vpnServerButton.staticTexts["Philippines"].exists).to(beTrue())
                }
            }
        }
    }
}
