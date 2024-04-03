//
//  DedicatedIPTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 27/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble

class DedicatedIPTests: BaseTest {
    override class func spec() {
        super.spec()
        
        describe("dedicated ip tests") {
            context("when activating dedicated ip tokens") {
                it("should display an error notification for invalid tokens") {
                    app.navigateToSettingsScreen()
                    app.navigateToDedicatedIPScreen()
                    if(app.deleteDedicatedIPButton.exists) {
                        app.deleteDedicatedIP()
                    }
                    app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .invalid))
                    expect(app.invalidTokenErrorMessage.waitForElementToAppear()).to(beTrue())
                }
                
                it("should display an error notification for empty token") {
                    app.navigateToSettingsScreen()
                    app.navigateToDedicatedIPScreen()
                    if(app.deleteDedicatedIPButton.exists) {
                        app.deleteDedicatedIP()
                    }
                    app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .empty))
                    expect(app.emptyTokenErrorMessage.waitForElementToAppear()).to(beTrue())
                }
                
                it("should successully activate valid tokens") {
                    app.navigateToSettingsScreen()
                    app.navigateToDedicatedIPScreen()
                    if(app.deleteDedicatedIPButton.exists) {
                        app.deleteDedicatedIP()
                    }
                    app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .valid))
                    expect(app.activeDIPStatus.waitForElementToAppear()).to(beTrue())
                }
            }
            
            context("when deleting dedicated ip") {
                it("should remove the dip from the list") {
                    app.navigateToSettingsScreen()
                    app.navigateToDedicatedIPScreen()
                    if(!app.deleteDedicatedIPButton.exists) {
                        app.activateDIPToken(DIP: DedicatedIPUtil.dedicatedIP(type: .valid))
                    }
                    app.deleteDedicatedIP()
                    expect(app.enterDedicatedIPTitle.waitForElementToAppear()).to(beTrue())
                }
            }
        }
    }
}
