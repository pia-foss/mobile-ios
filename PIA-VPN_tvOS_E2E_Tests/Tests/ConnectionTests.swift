//
//  ConnectionTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 3/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble

class ConnectionTests: BaseTest {
    override class func spec() {
        super.spec()
        
        describe("connection tests"){
            context("when in the dashboard screen"){
                it("should update the status to 'connected' when the user clicks the connect button from disconnected state"){
                    app.connect()
                    expect(app.connectedStatus.waitForElementToAppear()).to(beTrue())
                }
                
                it("should update the status to 'not connected' when the user clicks the connect button from connected state"){
                    app.connect()
                    app.disconnect()
                    expect(app.notConnectedStatus.waitForElementToAppear()).to(beTrue())
                }
            }
            
            context("when connecting to a specific location"){
                it("should allow the user to connect to the selectied location"){
                    app.navigateToLocationSelectionScreen()
                    app.navigateToSearchLocationScreen()
                    app.connectTo(region: "Peru")
                    expect(app.connectedStatus.waitForElementToAppear()).to(beTrue())
                    expect(app.selectedLocationButton.label.contains("Peru")).to(beTrue())
                }
                
                it("should allow the user to connect to previously connected location on the quick locations") {
                    app.navigateToLocationSelectionScreen()
                    app.navigateToSearchLocationScreen()
                    app.connectTo(region: "Peru")
                    expect(app.selectedLocationButton.label.contains("Peru")).to(beTrue())
                    
                    app.navigateToLocationSelectionScreen()
                    app.navigateToSearchLocationScreen()
                    app.connectTo(region: "Ohio")
                    expect(app.selectedLocationButton.label.contains("Ohio")).to(beTrue())
                    expect(app.button(with: "PE").waitForElementToAppear()).to(beTrue())
                    
                    app.navigateToLocationSelectionScreen()
                    app.navigateToSearchLocationScreen()
                    app.connectTo(region: "Nepal")
                    expect(app.selectedLocationButton.label.contains("Nepal")).to(beTrue())
                    expect(app.button(with: "US").waitForElementToAppear()).to(beTrue())
                }
            }
        }
    }
}
