//
//  UpdateSettingsTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 1/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class UpdateSettingsTests : BaseTest {
    override class func spec() {
        let geoLocatedRegionDefaultValue = "1"
        let vpnKillSwitchDefaultValue = "1"
        let automationDefaultValue = "0"
        
        super.spec()
        
        describe("settings return to default value after logging out") {
            context("updated settings for each category") {
                it("should revert changes made on general settings to default after logging out and logging back in") {
                    app.navigateToGeneralSettings()
                    app.geoLocatedRegionsSwitch.tap()
                    
                  // This check is flaky in CI because the switch has a small animation and there is a small amount of delay when the value gets updated after tapping the switch.
                    // TODO: Enable this check when we disable the animations on E2E tests
                    // expect((app.geoLocatedRegionsSwitch.value as! String)) != geoLocatedRegionDefaultValue
                    
                    app.navigateToHomeFromSettings()
                    app.logOut()
                    app.navigateToLoginScreen()
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptVPNPermission()
                    app.navigateToGeneralSettings()
                    expect((app.geoLocatedRegionsSwitch.value as! String)) == geoLocatedRegionDefaultValue
                }
                
                it("should revert changes made on protocol settings to default after logging out and logging back in") {
                    app.navigateToProtocolSettings()
                    app.protocolSelectionButton.tap()
                    app.openVPN.tap()
                    expect(app.openVPN.exists).to(beTrue())
                    app.navigateToHomeFromSettings()
                    app.logOut()
                    app.navigateToLoginScreen()
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptVPNPermission()
                    app.navigateToProtocolSettings()
                    expect(app.ipsec.exists).to(beTrue())
                }
                
                it("should revert changes made on privacy features settings to default after logging out and logging back in") {
                    app.navigateToPrivacySettings()
                    app.vpnKillSwitch.tap()
                    expect((app.vpnKillSwitch.value as! String)) != vpnKillSwitchDefaultValue
                    app.navigateToHomeFromSettings()
                    app.logOut()
                    app.navigateToLoginScreen()
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptVPNPermission()
                    app.navigateToPrivacySettings()
                    expect((app.vpnKillSwitch.value as! String)) == vpnKillSwitchDefaultValue
                }
                
                it("should revert changes made on automation settings to default after logging out and logging back in") {
                    app.navigateToAutomationSettings()
                    app.enableAutomationSwitch.tap()
                    
                    // This check is flaky in CI because the switch has a small animation and there is a small amount of delay when the value gets updated after tapping the switch.
                      // TODO: Enable this check when we disable the animations on E2E tests
                    // expect((app.enableAutomationSwitch.value as! String)) != automationDefaultValue
                    
                    app.navigateToHomeFromSettings()
                    app.logOut()
                    app.navigateToLoginScreen()
                    app.logIn(with: CredentialsUtil.credentials(type: .valid))
                    app.acceptVPNPermission()
                    app.navigateToAutomationSettings()
                    expect((app.enableAutomationSwitch.value as! String)) == automationDefaultValue
                }
            }
        }
    }
}
