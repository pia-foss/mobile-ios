//
//  DisplayedServerConnectionTimeTests.swift
//  PIA VPNTests
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
import PIALibrary
import Testing

@testable import PIA_VPN

@MainActor
@Suite(.serialized)
final class DisplayedServerConnectionTimeTests {

    private let oldConnectionSuccess = Date(timeIntervalSinceNow: -3600).timeIntervalSince1970
    private let vpnProvider = MockVPNProvider()
    private let serverProvider = Client.providers.serverProvider as! DefaultServerProvider
    private let originalVPNProvider = Client.providers.vpnProvider
    private let originalVPNStatus = Client.providers.vpnProvider.vpnStatus
    private let originalServers: [Server]
    private let originalPreferredServer = Client.preferences.preferredServer
    private let originalConnectionSuccess = Client.preferences.lastVPNConnectionSuccess

    init() {
        originalServers = serverProvider.currentServers
        serverProvider.currentServers = [makeServer("us-east"), makeServer("de-berlin")]
        Client.useMockVPNProvider(vpnProvider)
        setPreferredServer(makeServer("us-east"))
    }

    isolated deinit {
        setPreferredServer(originalPreferredServer)
        serverProvider.currentServers = originalServers
        vpnProvider.vpnStatus = originalVPNStatus
        Client.providers.vpnProvider = originalVPNProvider
        Client.preferences.lastVPNConnectionSuccess = originalConnectionSuccess
    }

    @Test func changingServerWhileConnectedResetsConnectionTime() throws {
        vpnProvider.vpnStatus = .connected
        Client.preferences.lastVPNConnectionSuccess = oldConnectionSuccess

        Client.preferences.displayedServer = makeServer("de-berlin")

        let connectionSuccess = try #require(Client.preferences.lastVPNConnectionSuccess)
        #expect(connectionSuccess > oldConnectionSuccess)
    }

    @Test func selectingSameServerWhileConnectedKeepsConnectionTime() {
        vpnProvider.vpnStatus = .connected
        Client.preferences.lastVPNConnectionSuccess = oldConnectionSuccess

        Client.preferences.displayedServer = makeServer("us-east")

        #expect(Client.preferences.lastVPNConnectionSuccess == oldConnectionSuccess)
    }

    @Test func changingServerWhileDisconnectedDoesNotSetConnectionTime() {
        vpnProvider.vpnStatus = .disconnected
        Client.preferences.lastVPNConnectionSuccess = nil

        Client.preferences.displayedServer = makeServer("de-berlin")

        #expect(Client.preferences.lastVPNConnectionSuccess == nil)
    }

    private func setPreferredServer(_ server: Server?) {
        let preferences = Client.preferences.editable()
        preferences.preferredServer = server
        preferences.commit()
    }

    private func makeServer(_ identifier: String) -> Server {
        Server(
            serial: "",
            name: identifier,
            country: "",
            hostname: "\(identifier).privacy.network",
            pingAddress: nil,
            regionIdentifier: identifier
        )
    }
}
