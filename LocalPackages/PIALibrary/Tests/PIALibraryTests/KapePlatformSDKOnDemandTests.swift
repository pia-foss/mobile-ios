//
//  KapePlatformSDKOnDemandTests.swift
//  PIALibraryTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import NetworkExtension
import XCTest

@testable import PIALibrary

/// Locks the Connect-on-Demand arming policy of the PlatformSDK profile: saving the NE
/// configuration while the tunnel is down (a Settings save, e.g. a protocol change) must never
/// arm on-demand, because a catch-all `NEOnDemandRuleConnect` makes iOS bring the tunnel up on
/// its own — connecting a user who deliberately stays disconnected.
final class KapePlatformSDKOnDemandTests: XCTestCase {

    private func makeSubject() -> (KapePlatformSDKTunnelProfile, NETunnelProviderManager) {
        Client.database = Client.Database(group: "group.com.privateinternetaccess")
        Client.providers.vpnProvider = MockVPNProvider()
        Client.useMockServerProvider()

        let account = EphemeralAccountProvider()
        account.isLoggedIn = true
        account.vpnToken = "USER:PASS"
        account.vpnTokenUsername = "USER"
        account.vpnTokenPassword = "PASS"
        Client.providers.accountProvider = account

        // The kill switch — the toggle that becomes `configuration.isOnDemand` — is on by default.
        let preferences = Client.preferences.editable()
        preferences.isPersistentConnection = true
        preferences.nmtRulesEnabled = false
        preferences.commit()

        let profile = KapePlatformSDKTunnelProfile(
            bundleIdentifier: "com.privateinternetaccess.ios.PIA-VPN.PlatformSDK-Tunnel")

        // An enabled manager is what the app always has once the user has connected at least
        // once: `doSave` sets `isEnabled = true` and nothing ever clears it, and `disconnect()`
        // only clears `isOnDemandEnabled`.
        let vpn = NETunnelProviderManager()
        vpn.isEnabled = true
        vpn.isOnDemandEnabled = false

        return (profile, vpn)
    }

    private func makeConfiguration() -> VPNConfiguration {
        VPNConfiguration(
            name: "PIA",
            username: "USER",
            passwordReference: Data(),
            server: Server(
                serial: "serial-1",
                name: "Server 1",
                country: "us",
                hostname: "server1.example.com",
                pingAddress: nil,
                regionIdentifier: "region-1"
            ),
            isOnDemand: true,
            disconnectsOnSleep: false,
            customConfiguration: nil,
            leakProtection: false,
            allowLocalDeviceAccess: false
        )
    }

    /// The reported bug: disconnected + a Settings save (`force == false`, the value
    /// `DefaultVPNProvider.install` passes while the status is not connected/connecting).
    func testSavingWhileDisconnectedDoesNotArmOnDemand() {
        let (profile, vpn) = makeSubject()
        XCTAssertEqual(Client.providers.vpnProvider.vpnStatus, .disconnected)

        profile.doSave(vpn, withConfiguration: makeConfiguration(), force: false, nil)

        XCTAssertFalse(
            vpn.isOnDemandEnabled,
            "on-demand must stay disarmed while the user is disconnected")
        XCTAssertTrue(
            vpn.onDemandRules?.isEmpty ?? true,
            "no on-demand rule may be installed while the user is disconnected")
    }

    /// The behaviour that must survive the fix: a user-initiated connect saves with
    /// `force == true`, and the kill switch has to be armed for that session.
    func testConnectArmsOnDemandEvenThoughTheTunnelIsNotUpYet() {
        let (profile, vpn) = makeSubject()
        XCTAssertEqual(Client.providers.vpnProvider.vpnStatus, .disconnected)

        profile.doSave(vpn, withConfiguration: makeConfiguration(), force: true, nil)

        XCTAssertTrue(
            vpn.isOnDemandEnabled,
            "the kill switch must be armed when the user asks to connect")
        XCTAssertTrue(
            vpn.onDemandRules?.contains(where: { $0 is NEOnDemandRuleConnect }) ?? false,
            "the kill switch is implemented as a catch-all connect rule")
    }
}
