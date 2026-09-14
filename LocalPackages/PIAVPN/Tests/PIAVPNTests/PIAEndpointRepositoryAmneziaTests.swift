import Foundation
import KapeVPN_PacketTunnel
import PIALibrary
import Testing

@testable import PIAVPN

@Suite("AmneziaWG endpoint generation")
struct PIAEndpointRepositoryAmneziaTests {

    private static func address(_ ip: String, cn: String, port: UInt16? = nil) -> Server.ServerAddressIP {
        Server.ServerAddressIP(ip: ip, cn: cn, van: true, port: port)
    }

    private static func server(
        wireGuard: [Server.ServerAddressIP]? = nil,
        amnezia: [Server.ServerAddressIP]? = nil
    ) -> Server {
        Server(
            serial: "1",
            name: "US Seattle",
            country: "US",
            hostname: "us-seattle.pvt.site",
            wireGuardAddressesForUDP: wireGuard,
            amneziaAddressesForUDP: amnezia,
            pingAddress: nil,
            regionIdentifier: "us_seattle"
        )
    }

    private static let amneziaObfuscation = PIAEndpointRepository.amneziaPlaceholder

    @Test("the amnezia step uses the awg addresses and their port")
    func amneziaUsesAmneziaAddressesAndPort() {
        let server = Self.server(
            wireGuard: [Self.address("1.1.1.1", cn: "wg-cn")],
            amnezia: [Self.address("2.2.2.2", cn: "awg-cn", port: 1338)]
        )

        let configurations = PIAEndpointRepository().generateWireGuardConfigurations(
            server: server,
            state: PIATunnelSharedState.read(),
            obfuscation: Self.amneziaObfuscation,
            port: PIAEndpointRepository.amneziaPort
        )

        #expect(configurations.count == 1)
        let endpoint = configurations.first?.connectedEndpointSnapshot
        #expect(endpoint?.host == "2.2.2.2")
        #expect(endpoint?.port == 1338)
        #expect(endpoint?.obfuscationDescription == "amnezia")
    }

    @Test("a plain wireguard step ignores the awg addresses")
    func wireGuardIgnoresAmneziaAddresses() {
        let server = Self.server(
            wireGuard: [Self.address("1.1.1.1", cn: "wg-cn")],
            amnezia: [Self.address("2.2.2.2", cn: "awg-cn", port: 1338)]
        )

        let configurations = PIAEndpointRepository().generateWireGuardConfigurations(
            server: server,
            state: PIATunnelSharedState.read()
        )

        #expect(configurations.count == 1)
        let endpoint = configurations.first?.connectedEndpointSnapshot
        #expect(endpoint?.host == "1.1.1.1")
        #expect(endpoint?.port == PIAEndpointRepository.wireGuardPort)
        #expect(endpoint?.obfuscationDescription == "none")
    }

    @Test("an address without a port falls back to the step's port")
    func portFallsBackToStepPort() {
        let server = Self.server(amnezia: [Self.address("2.2.2.2", cn: "awg-cn")])

        let configurations = PIAEndpointRepository().generateWireGuardConfigurations(
            server: server,
            state: PIATunnelSharedState.read(),
            obfuscation: Self.amneziaObfuscation,
            port: PIAEndpointRepository.amneziaPort
        )

        #expect(configurations.first?.connectedEndpointSnapshot?.port == PIAEndpointRepository.amneziaPort)
    }

    @Test("a server without awg addresses contributes nothing to the amnezia step")
    func noAmneziaAddressesContributesNothing() {
        let server = Self.server(wireGuard: [Self.address("1.1.1.1", cn: "wg-cn")])

        let configurations = PIAEndpointRepository().generateWireGuardConfigurations(
            server: server,
            state: PIATunnelSharedState.read(),
            obfuscation: Self.amneziaObfuscation,
            port: PIAEndpointRepository.amneziaPort
        )

        #expect(configurations.isEmpty)
    }

    @Test("the censorship order tries amnezia before plain wireguard")
    func censorshipOrderPrefersAmnezia() {
        let server = Self.server(
            wireGuard: [Self.address("1.1.1.1", cn: "wg-cn")],
            amnezia: [Self.address("2.2.2.2", cn: "awg-cn", port: 1338)]
        )

        let batch = PIAEndpointRepository().automaticConfigurations(
            servers: [server],
            state: PIATunnelSharedState.read(),
            order: PIAEndpointRepository.censorshipPeckingOrder
        )

        let wireGuardSteps = batch.compactMap(\.connectedEndpointSnapshot).filter {
            $0.protocolDescription.hasPrefix("WireGuard")
        }
        #expect(wireGuardSteps.first?.host == "2.2.2.2")
        #expect(wireGuardSteps.first?.obfuscationDescription == "amnezia")
        #expect(wireGuardSteps.dropFirst().first?.host == "1.1.1.1")
        #expect(wireGuardSteps.dropFirst().first?.obfuscationDescription == "none")
    }

    @Test("the normal order falls back to amnezia only after the plain protocols")
    func normalOrderTriesAmneziaLast() throws {
        let server = Self.server(
            wireGuard: [Self.address("1.1.1.1", cn: "wg-cn")],
            amnezia: [Self.address("2.2.2.2", cn: "awg-cn", port: 1338)]
        )

        let batch = PIAEndpointRepository().automaticConfigurations(
            servers: [server],
            state: PIATunnelSharedState.read(),
            order: PIAEndpointRepository.normalPeckingOrder
        )

        let snapshots = batch.compactMap(\.connectedEndpointSnapshot)
        let firstAmnezia = try #require(snapshots.firstIndex { $0.obfuscationDescription == "amnezia" })
        let lastPlain = try #require(snapshots.lastIndex { $0.obfuscationDescription != "amnezia" })
        #expect(firstAmnezia > lastPlain)
        #expect(snapshots[firstAmnezia].host == "2.2.2.2")
    }
}
