//
//  DedicatedIPTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble

class DedicatedIPTests: BaseTest {
    override class func spec() {
        super.spec()
        
        describe("dedicated ip tests") {
            beforeEach {
                app.navigateToDedicatedIPScreen()
                if(app.dedicatedIPList.waitForExistence(timeout: app.defaultTimeout)) {
                    app.deleteDedicatedIP()
                }
                app.navigateToHome(using: app.closeButton)
            }
            
            context("dedicated ip validation") {
                it("should successfully add a valid token") {
                    app.navigateToDedicatedIPScreen()
                    app.activateDedicatedIP(with: DedicatedIPUtil.dedicatedIP(type: .valid))
                    expect(app.dedicatedIPList.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
                
                it("should display an error message when adding invalid token") {
                    app.navigateToDedicatedIPScreen()
                    app.activateDedicatedIP(with: DedicatedIPUtil.dedicatedIP(type: .invalid))
                    expect(app.invalidTokenErrorMessage.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
                
                it("should display an error message when adding empty token") {
                    app.navigateToDedicatedIPScreen()
                    app.activateDedicatedIP(with: DedicatedIPUtil.dedicatedIP(type: .empty))
                    expect(app.emptyTokenErrorMessage.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
            }
            
            context("managing dedicated ip") {
                xit("should be able to connect successfully on a valid dedicated ip") {
                    app.navigateToDedicatedIPScreen()
                    app.activateDedicatedIP(with: DedicatedIPUtil.dedicatedIP(type: .valid))
                    app.navigateToHome(using: app.closeButton)
                    app.navigateToRegionSelection()
                    let firstRegion = app.getRegionList().staticTexts["DEDICATED IP"]
                    //active bug: https://polymoon.atlassian.net/browse/PIA-1107
                    expect(firstRegion.staticTexts["DEDICATED IP"].waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    firstRegion.tap()
                    expect(app.connectedStatusLabel.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.regionTileCollectionViewCell.staticTexts["DEDICATED IP"].waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
                
                it("should be able to successfully delete a listed dedicated ip") {
                    app.navigateToDedicatedIPScreen()
                    app.activateDedicatedIP(with: DedicatedIPUtil.dedicatedIP(type: .valid))
                    app.deleteDedicatedIP()
                    expect(app.dedicatedIPTextField.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
            }
        }
    }
}
