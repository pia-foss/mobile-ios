//
//  SettingsTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 1/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class SettingsTests : BaseTest {
    override class func spec() {
        let geoLocatedRegionDefaultValue = "1"
        let vpnKillSwitchDefaultValue = "1"
        let automationDefaultValue = "0"
        
        super.spec()
        
        describe("settings tests") {
            context("updated settings for each category") {
                it("should revert changes made on to default value after logging out and logging back in") {
                    //update general settings
                    app.navigateToGeneralSettings()
                    app.disableGeoLocatedRegionSwitch()
                    
                  // This check is flaky in CI because the switch has a small animation and there is a small amount of delay when the value gets updated after tapping the switch.
                    // TODO: Enable this check when we disable the animations on E2E tests
                    // expect((app.geoLocatedRegionsSwitch.value as! String)) != geoLocatedRegionDefaultValue
                    
                    //update protocol settings
                    app.navigateToHomeFromSettings()
                    app.navigateToProtocolSettings()
                    app.selectProtocol(protocolName: "OpenVPN")
                    expect(app.openVPN.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    
                    //update privacy settings
                    app.navigateToHomeFromSettings()
                    app.navigateToPrivacySettings()
                    app.disableVPNKillSwitch()
                    expect((app.vpnKillSwitch.value as! String)) != vpnKillSwitchDefaultValue
                    
                    //update automation settings
                    app.navigateToHomeFromSettings()
                    app.navigateToAutomationSettings()
                    app.enableAutomationSwitch.tap()
                    
                    app.navigateToHomeFromSettings()
                    app.logOut()
                    app.navigateToLoginScreen()
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptVPNPermission()
                    
                    //expect that the settings are reverted to default value
                    app.navigateToGeneralSettings()
                    expect((app.geoLocatedRegionsSwitch.value as! String)) == geoLocatedRegionDefaultValue
                    
                    app.navigateToHomeFromSettings()
                    app.navigateToProtocolSettings()
                    expect(app.wireguard.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    
                    app.navigateToHomeFromSettings()
                    app.navigateToPrivacySettings()
                    expect((app.vpnKillSwitch.value as! String)) == vpnKillSwitchDefaultValue
                    
                    app.navigateToHomeFromSettings()
                    app.navigateToAutomationSettings()
                    expect((app.enableAutomationSwitch.value as! String)) == automationDefaultValue
                }
                
                context("help settings interaction") {
                    it("should return 'Debug information submitted' when user clicks 'Send Debug Log to support'") {
                        app.navigateToHelpSettings()
                        app.sendDebugButton.tap()
                        //active bug: this returns error in simulator
                        expect(app.successfulSendDebugMessage.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    }
                    
                    it("should when user clicks 'Latest News'") {
                        app.navigateToHelpSettings()
                        app.latestNewsButton.tap()
                        expect(app.tryWireguardNowButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                        
                        app.tryWireguardNowButton.tap()
                        expect(app.protocolsSettingsButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                        expect(app.wireguard.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    }
                    
                    it("should when user clicks 'Help improve PIA'") {
                        app.navigateToHelpSettings()
                        app.enableHelpImprovePIA()
                        expect(app.connectionStatsButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    }
                    
                    it("should display version number") {
                        app.navigateToHelpSettings()
                        expect(app.versionNo.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    }
                }
            }
        }
    }
}
