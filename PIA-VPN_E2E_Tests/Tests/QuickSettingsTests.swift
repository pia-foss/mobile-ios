//
//  QuickSettingsTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 15/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class QuickSettingsTests: BaseTest {
    override class func spec() {
        super.spec()

        describe("quick settings on homescreen tests") {
            context("when quick settings items are displayed on homescreen") {
                it("should show every shortcut") {
                    expect(app.privateBrowserButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                    expect {
                        app.enableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)
                            || app.disableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)
                    }.to(beTrue())
                    expect {
                        app.enableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)
                            || app.disableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)
                    }.to(beTrue())
                }

                it("should indicate that it's enabled when the user enables it") {
                    app.enableVPNKillSwitchOnHome()
                    expect(app.disableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())

                    app.enableNetworkManagementOnHome()
                    expect(app.disableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }

                it("should indicate that it's disabled when the user disables it") {
                    app.disableVPNKillSwitchOnHome()
                    expect(app.enableVPNKillSwitchButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())

                    app.enableVPNKillSwitchOnHome()
                    app.disableNetworkManagementOnHome()
                    expect(app.enableNetworkManagementButton.waitForExistence(timeout: app.defaultTimeout)).to(beTrue())
                }

                xit("should display a notification message and not allow enabling the network management when vpn kill switch is disabled") {
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
        }
    }
}
