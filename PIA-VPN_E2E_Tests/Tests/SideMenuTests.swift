//
//  SideMenuTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 9/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble

class SideMenuTests: BaseTest {
    override class func spec() {
        super.spec()
        
        describe("side menu tests") {
            context("when an item is selected from the side menu") {
                it("when region selectionshould be redirected to its respective navigation") {
                    if(app.closeButton.exists){
                        app.navigateToHome()
                    }
                    app.selectSideMenu(menuName: "Region selection")
                    expect(app.regionSelectionHeader.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    
                    app.navigateToHome()
                    app.selectSideMenu(menuName: "Account")
                    expect(app.staticText(with: "Account").waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    
                    app.navigateToHome()
                    app.selectSideMenu(menuName: "About")
                    expect(app.staticText(with: "About").waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
            }
        }
    }
}
