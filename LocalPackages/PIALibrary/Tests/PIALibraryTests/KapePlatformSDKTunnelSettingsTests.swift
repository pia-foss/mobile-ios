//
//  KapePlatformSDKTunnelSettingsTests.swift
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

import Foundation
import NetworkExtension
import Testing

@testable import PIALibrary

/// Covers which credential failures may abort a connect.
///
/// The bug these lock down: `writeSharedState` used to build *both* protocols' settings
/// unconditionally, so an OpenVPN credential failure aborted a WireGuard (or Automatic) connect that
/// had everything it needed. This is reachable because the two protocols read the VPN token
/// differently — OpenVPN splits it into `user:pass`
/// (`DefaultAccountProvider.getVpnTokenUsernameAndPassword`) while WireGuard uses it whole — so a
/// token that isn't a `user:pass` pair leaves WireGuard fully provisioned and OpenVPN with nothing.
///
/// Serialized because every case mutates process-global `Client` state.
@Suite("KapePlatformSDK tunnel settings", .serialized)
struct KapePlatformSDKTunnelSettingsTests {

    // MARK: - Fixtures

    /// - Parameters:
    ///   - vpnToken: the raw account token; `nil` leaves the account with no token at all.
    ///   - splitsIntoUserPass: whether the token also yields OpenVPN's username/password. Set `false`
    ///     to model the reported bug — a native `syncVpnToken` that isn't in `user:pass` form.
    @discardableResult
    private func makeAccount(
        vpnToken: String?,
        splitsIntoUserPass: Bool = true
    ) -> EphemeralAccountProvider {
        let account = EphemeralAccountProvider()
        account.isLoggedIn = true
        account.vpnToken = vpnToken
        if let vpnToken, splitsIntoUserPass {
            let parts = vpnToken.components(separatedBy: ":")
            account.vpnTokenUsername = parts.first
            account.vpnTokenPassword = parts.last
        }
        Client.providers.accountProvider = account
        return account
    }

    private func makeProfile() -> KapePlatformSDKTunnelProfile {
        Client.database = Client.Database(group: "group.com.privateinternetaccess")
        Client.providers.vpnProvider = MockVPNProvider()
        Client.useMockServerProvider()
        return KapePlatformSDKTunnelProfile(
            bundleIdentifier: "com.privateinternetaccess.ios.PIA-VPN.PlatformSDK-Tunnel")
    }

    private func makeServer(
        hostname: String = "server1.example.com",
        openVPNAddressesForUDP: [Server.ServerAddressIP]? = [.init(ip: "1.2.3.4", cn: "cn", van: false)],
        wireGuardAddressesForUDP: [Server.ServerAddressIP]? = [.init(ip: "1.2.3.4", cn: "cn", van: false)],
        dipToken: String? = nil,
        dipUsername: String? = nil
    ) -> Server {
        Server(
            serial: "serial-1",
            name: "Server 1",
            country: "us",
            hostname: hostname,
            openVPNAddressesForUDP: openVPNAddressesForUDP,
            wireGuardAddressesForUDP: wireGuardAddressesForUDP,
            pingAddress: nil,
            dipToken: dipToken,
            dipUsername: dipUsername,
            regionIdentifier: "region-1"
        )
    }

    private func makeConfiguration(server: Server) -> VPNConfiguration {
        VPNConfiguration(
            name: "PIA",
            username: "USER",
            passwordReference: Data(),
            server: server,
            isOnDemand: false,
            disconnectsOnSleep: false,
            customConfiguration: nil,
            leakProtection: false,
            allowLocalDeviceAccess: false
        )
    }

    private func selectProtocol(_ vpnType: KapePlatformSDKVPNType) {
        let preferences = Client.preferences.editable()
        preferences.vpnType = vpnType.rawValue
        preferences.isPersistentConnection = false
        preferences.nmtRulesEnabled = false
        preferences.commit()
    }

    /// The error `doSave` reports *synchronously*.
    ///
    /// Every `TunnelSettingsError` is raised before `saveToPreferences`, so the abort path always
    /// calls back inline; the success path only calls back later, from Network Extension's
    /// asynchronous save (which a unit-test process cannot complete anyway). A `nil` here therefore
    /// means "the connect was not aborted over credentials", which is exactly what is under test.
    private func synchronousError(
        from profile: KapePlatformSDKTunnelProfile,
        server: Server
    ) -> Error? {
        var reported: Error?
        profile.doSave(
            NETunnelProviderManager(),
            withConfiguration: makeConfiguration(server: server),
            force: true
        ) { error in
            reported = error
        }
        return reported
    }

    // MARK: - OpenVPN settings

    @Test("OpenVPN settings need the token to split into user:pass")
    func openVPNRequiresSplittableToken() {
        let profile = makeProfile()
        makeAccount(vpnToken: "not-a-pair", splitsIntoUserPass: false)

        #expect(throws: TunnelSettingsError.credentialsUnavailable(protocol: .openVPN)) {
            try profile.openVPNSettings(for: makeServer())
        }
    }

    @Test("OpenVPN settings carry the split token as username/password")
    func openVPNUsesSplitToken() throws {
        let profile = makeProfile()
        makeAccount(vpnToken: "USER:PASS")

        let settings = try profile.openVPNSettings(for: makeServer())

        #expect(settings.username == "USER")
        #expect(settings.password == "PASS")
    }

    @Test("A DIP server with no resolvable IP has no OpenVPN password")
    func openVPNDIPWithoutAddress() {
        let profile = makeProfile()
        makeAccount(vpnToken: "USER:PASS")
        let server = makeServer(
            openVPNAddressesForUDP: nil, dipToken: "dip-token", dipUsername: "dedicated_ip_abc")

        #expect(
            throws: TunnelSettingsError.dedicatedIPUnavailable(
                protocol: .openVPN, serverIdentifier: server.identifier)
        ) {
            try profile.openVPNSettings(for: server)
        }
    }

    // MARK: - WireGuard settings

    @Test("WireGuard settings only need the raw token, not a user:pass pair")
    func wireGuardAcceptsUnsplittableToken() throws {
        let profile = makeProfile()
        makeAccount(vpnToken: "not-a-pair", splitsIntoUserPass: false)

        // The crux of the reported bug: this is the state in which OpenVPN has nothing and
        // WireGuard is fully provisioned.
        #expect(try profile.wireGuardSettings(for: makeServer()).token == "not-a-pair")
    }

    @Test("WireGuard settings need a token")
    func wireGuardRequiresToken() {
        let profile = makeProfile()
        makeAccount(vpnToken: nil)

        #expect(throws: TunnelSettingsError.credentialsUnavailable(protocol: .wireGuard)) {
            try profile.wireGuardSettings(for: makeServer())
        }
    }

    @Test("A DIP server authenticates WireGuard with its dipUsername")
    func wireGuardDIPUsesDipUsername() throws {
        let profile = makeProfile()
        makeAccount(vpnToken: "USER:PASS")
        let server = makeServer(dipToken: "dip-token", dipUsername: "dedicated_ip_abc")

        #expect(try profile.wireGuardSettings(for: server).token == "dedicated_ip_abc")
    }

    @Test("A DIP server with no dipUsername does not fall back to the account token")
    func wireGuardDIPWithoutUsername() {
        let profile = makeProfile()
        makeAccount(vpnToken: "USER:PASS")
        let server = makeServer(dipToken: "dip-token", dipUsername: nil)

        // Falling through to the account token would authenticate against a DIP endpoint with
        // account credentials — a wrong-credentials attempt instead of a clean failure.
        #expect(
            throws: TunnelSettingsError.dedicatedIPUnavailable(
                protocol: .wireGuard, serverIdentifier: server.identifier)
        ) {
            try profile.wireGuardSettings(for: server)
        }
    }

    // MARK: - Which failures abort a connect

    @Test(
        "Unavailable OpenVPN credentials do not abort a connect that does not need them",
        arguments: [KapePlatformSDKVPNType.wireGuard, .automatic]
    )
    func openVPNCredentialsAreNotRequiredByOtherProtocols(vpnType: KapePlatformSDKVPNType) {
        let profile = makeProfile()
        makeAccount(vpnToken: "not-a-pair", splitsIntoUserPass: false)
        selectProtocol(vpnType)

        #expect(synchronousError(from: profile, server: makeServer()) == nil)
    }

    @Test("Unavailable OpenVPN credentials abort an OpenVPN connect")
    func openVPNCredentialsAreRequiredByOpenVPN() {
        let profile = makeProfile()
        makeAccount(vpnToken: "not-a-pair", splitsIntoUserPass: false)
        selectProtocol(.openVPN)

        #expect(
            synchronousError(from: profile, server: makeServer()) as? TunnelSettingsError
                == .credentialsUnavailable(protocol: .openVPN))
    }

    @Test("Unavailable WireGuard credentials abort a WireGuard connect")
    func wireGuardCredentialsAreRequiredByWireGuard() {
        let profile = makeProfile()
        makeAccount(vpnToken: nil)
        selectProtocol(.wireGuard)

        #expect(
            synchronousError(from: profile, server: makeServer()) as? TunnelSettingsError
                == .credentialsUnavailable(protocol: .wireGuard))
    }

    @Test("Automatic aborts only when neither protocol is usable")
    func automaticRequiresOneUsableProtocol() {
        let profile = makeProfile()
        makeAccount(vpnToken: nil)
        selectProtocol(.automatic)

        // Without this the tunnel would start with no usable credentials for either protocol and
        // could not possibly connect.
        #expect(
            synchronousError(from: profile, server: makeServer()) as? TunnelSettingsError
                == .noProtocolAvailable)
    }
}
