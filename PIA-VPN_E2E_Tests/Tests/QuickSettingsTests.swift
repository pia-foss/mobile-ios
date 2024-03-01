//
//  QuickSettingsTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 15/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class QuickSettingsTests : BaseTest {
    override class func spec() {
        let enabledValue = "1"
        let disabledValue = "0"
        
        super.spec()
        
        describe("quick settings on homescreen tests") {
            context("when quick settings items are displayed on homescreen") {
                it("should indicate that it's enabled when the user enables it") {
                    app.navigateToQuickSettings()
                    app.enableVPNKillSwitchQuickSetting()
                    app.enableNetworkManagementQuickSetting()
                    
                    app.navigateToHome(using: app.closeButton)
                    
                    app.enableVPNKillSwitchOnHome()
                    expect(app.disableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    
                    app.enableNetworkManagementOnHome()
                    expect(app.disableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
                
                it("should indicate that it's disabled when the user disables it") {
                    app.navigateToQuickSettings()
                    app.enableVPNKillSwitchQuickSetting()
                    app.enableNetworkManagementQuickSetting()
                    
                    app.navigateToHome(using: app.closeButton)
                    
                    app.disableVPNKillSwitchOnHome()
                    expect(app.enableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    
                    app.enableVPNKillSwitchOnHome()
                    app.disableNetworkManagementOnHome()
                    expect(app.enableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
                
                
                it("should display a notification message and not allow enabling the network management when vpn kill switch is disabled") {
                    app.navigateToQuickSettings()
                    app.enableVPNKillSwitchQuickSetting()
                    app.enableNetworkManagementQuickSetting()
                    
                    app.navigateToHome(using: app.closeButton)
                    
                    app.enableVPNKillSwitchOnHome()
                    app.disableVPNKillSwitchOnHome()
                    app.enableNetworkManagementOnHome()
                    
                    app.staticText(with: "ENABLE").tap()
                    expect(app.disableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.disableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    
                    app.disableVPNKillSwitchOnHome()
                    app.staticText(with: "CLOSE").tap()
                    
                    //active bug: https://polymoon.atlassian.net/browse/PIA-938
                    expect(app.enableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect(app.enableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
            }
            
            context("when selecting items to be displayed for Quick Settings") {
                it("should not display disabled selection on homescreen") {
                    app.navigateToQuickSettings()
                    
                    app.disableVPNKillSwitchQuickSetting()
                    expect(app.vpnKillSwitchQuickSettings.value as! String == disabledValue).to(beTrue())
                    app.navigateToHome(using: app.closeButton)
                    expect{
                        let enableVPNKillSwitchButtonPresent = app.enableVPNKillSwitchButton.exists
                        let disableVPNKillSwitchButtonPresent = app.disableVPNKillSwitchButton.exists
                        return enableVPNKillSwitchButtonPresent || disableVPNKillSwitchButtonPresent
                    }.to(beFalse())
                    
                    app.navigateToQuickSettings()
                    app.enableVPNKillSwitchQuickSetting()
                    expect(app.vpnKillSwitchQuickSettings.value as! String == enabledValue).to(beTrue())
                    app.disableNetworkManagementQuickSetting()
                    expect(app.networkManagementQuickSettings.value as! String == disabledValue).to(beTrue())
                    app.navigateToHome(using: app.closeButton)
                    expect{
                        let enableNetworkManagementButtonPresent = app.enableNetworkManagementButton.exists
                        let disableNetworkManagementButtonPresent = app.disableNetworkManagementButton.exists
                        return enableNetworkManagementButtonPresent || disableNetworkManagementButtonPresent
                    }.to(beFalse())

                    app.navigateToQuickSettings()
                    app.disablePrivateBrowserQuickSetting()
                    expect(app.privateBrowserQuickSettings.value as! String == disabledValue).to(beTrue())
                    app.navigateToHome(using: app.closeButton)
                    expect(app.privateBrowserButton.exists).to(beFalse())
                    
                }
                
                it("should display enabled selection on homescreen") {
                    app.navigateToQuickSettings()
                    
                    app.enableVPNKillSwitchQuickSetting()
                    expect(app.vpnKillSwitchQuickSettings.value as! String == enabledValue).to(beTrue())
                    
                    app.enableNetworkManagementQuickSetting()
                    expect(app.networkManagementQuickSettings.value as! String == enabledValue).to(beTrue())
                    
                    app.enablePrivateBrowserQuickSetting()
                    expect(app.privateBrowserQuickSettings.value as! String == enabledValue).to(beTrue())
                    
                    app.navigateToHome(using: app.closeButton)
                    expect(app.privateBrowserButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect{
                        let enableVPNKillSwitchButtonPresent = app.enableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)
                        let disableVPNKillSwitchButtonPresent = app.disableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)
                        return enableVPNKillSwitchButtonPresent || disableVPNKillSwitchButtonPresent
                    }.to(beTrue())
                    expect{
                        let enableNetworkManagementButtonPresent = app.enableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)
                        let disableNetworkManagementButtonPresent = app.disableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)
                        return enableNetworkManagementButtonPresent || disableNetworkManagementButtonPresent
                    }.to(beTrue())
                }
                
                it("should return a notification message when all selections are being disabled") {
                    app.navigateToQuickSettings()
                    
                    app.disableVPNKillSwitchQuickSetting()
                    app.disableNetworkManagementQuickSetting()
                    app.disablePrivateBrowserQuickSetting()
                    expect(app.staticText(with: "You should keep at least one element visible in the Quick Settings Tile").waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }
            }
        }
    }
}
