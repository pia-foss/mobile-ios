import Foundation
import KapeVPN_OpenVPN
import KapeVPN_PacketTunnel
import KapeVPN_WireGuard
import PIALibrary
import Testing

@testable import PIAVPN

@Suite("Handing out configurations one at a time")
struct PIAEndpointRepositoryQueueTests {

    private struct FakeConfiguration: VpnConfiguration, Equatable {
        let name: String
        var vpnProtocolName: String { "fake" }
        #if DEBUG
            var endpointsCount: Int { 1 }
        #endif
    }

    private struct AuthorizationFailed: Error, Equatable {
        let name: String
    }

    /// Counts the batches built and serves them in order, then empty ones.
    private actor BatchSource {
        private var batches: [[FakeConfiguration]]
        private(set) var builds = 0

        init(_ batches: [[FakeConfiguration]]) {
            self.batches = batches
        }

        func build() -> [any VpnConfiguration] {
            builds += 1
            return batches.isEmpty ? [] : batches.removeFirst()
        }
    }

    private static func configuration(_ name: String) -> FakeConfiguration {
        FakeConfiguration(name: name)
    }

    private static func names(_ configuration: (any VpnConfiguration)?) -> String? {
        (configuration as? FakeConfiguration)?.name
    }

    private static func makeQueue() -> PIAEndpointRepository.ConfigurationQueue {
        PIAEndpointRepository.ConfigurationQueue(logger: PIATunnelLogger(label: "test"))
    }

    // MARK: ConfigurationQueue

    @Test("configurations come out in batch order, one per call, from a single build")
    func handsOutInOrder() async throws {
        let queue = Self.makeQueue()
        let source = BatchSource([[Self.configuration("a"), Self.configuration("b")]])

        let first = try await queue.next(buildBatch: { await source.build() }, authorize: { $0 })
        let second = try await queue.next(buildBatch: { await source.build() }, authorize: { $0 })

        #expect(Self.names(first) == "a")
        #expect(Self.names(second) == "b")
        #expect(await source.builds == 1)
    }

    @Test("a configuration that fails to authorize is skipped for the next one")
    func skipsUnauthorized() async throws {
        let queue = Self.makeQueue()
        let source = BatchSource([[Self.configuration("a"), Self.configuration("b")]])

        let next = try await queue.next(
            buildBatch: { await source.build() },
            authorize: { configuration in
                if Self.names(configuration) == "a" { throw AuthorizationFailed(name: "a") }
                return configuration
            }
        )

        #expect(Self.names(next) == "b")
    }

    @Test("when nothing authorizes, the last authorization error is thrown")
    func throwsLastAuthorizationError() async {
        let queue = Self.makeQueue()
        let source = BatchSource([[Self.configuration("a"), Self.configuration("b")]])

        await #expect(throws: AuthorizationFailed(name: "b")) {
            try await queue.next(
                buildBatch: { await source.build() },
                authorize: { throw AuthorizationFailed(name: Self.names($0) ?? "") }
            )
        }
    }

    @Test("an empty pool is rebuilt a bounded number of times, then nil")
    func boundedRefills() async throws {
        let queue = Self.makeQueue()
        let source = BatchSource([])

        let next = try await queue.next(buildBatch: { await source.build() }, authorize: { $0 })

        #expect(next == nil)
        #expect(await source.builds == PIAEndpointRepository.ConfigurationQueue.maxRefillsPerCall)
    }

    @Test("a refill that comes back non-empty is used within the same call")
    func refillsWithinCall() async throws {
        let queue = Self.makeQueue()
        let source = BatchSource([[], [Self.configuration("a")]])

        let next = try await queue.next(buildBatch: { await source.build() }, authorize: { $0 })

        #expect(Self.names(next) == "a")
        #expect(await source.builds == 2)
    }

    @Test("reset drops the rest of the batch, so the next call builds a new one")
    func resetDropsQueued() async throws {
        let queue = Self.makeQueue()
        let source = BatchSource([
            [Self.configuration("old-1"), Self.configuration("old-2")],
            [Self.configuration("new")]
        ])

        _ = try await queue.next(buildBatch: { await source.build() }, authorize: { $0 })
        await queue.reset()
        let next = try await queue.next(buildBatch: { await source.build() }, authorize: { $0 })

        #expect(Self.names(next) == "new")
        #expect(await source.builds == 2)
    }

    @Test("cancellation is rethrown instead of skipping to the next configuration")
    func rethrowsCancellation() async {
        let queue = Self.makeQueue()
        let source = BatchSource([[Self.configuration("a"), Self.configuration("b")]])

        await #expect(throws: CancellationError.self) {
            try await queue.next(buildBatch: { await source.build() }, authorize: { _ in throw CancellationError() })
        }
    }

    @Test("a cancelled task stops working through failing configurations")
    func stopsSkippingOnceCancelled() async {
        let queue = Self.makeQueue()
        let source = BatchSource([[Self.configuration("a"), Self.configuration("b")]])
        let attempts = CallCounter()

        await #expect(throws: CancellationError.self) {
            try await queue.next(
                buildBatch: { await source.build() },
                authorize: { configuration in
                    await attempts.increment()
                    // As when the tunnel stops while an authorization is failing on its own.
                    withUnsafeCurrentTask { $0?.cancel() }
                    throw AuthorizationFailed(name: Self.names(configuration) ?? "")
                }
            )
        }
        #expect(await attempts.count == 1)
    }

    @Test("only installed batches are reported, once each")
    func reportsInstalledBatches() async throws {
        let queue = Self.makeQueue()
        let source = BatchSource([[Self.configuration("a"), Self.configuration("b")]])
        let installs = CallCounter()

        for _ in 0..<2 {
            _ = try await queue.next(
                buildBatch: { await source.build() },
                authorize: { $0 },
                didInstall: { _ in await installs.increment() }
            )
        }

        #expect(await installs.count == 1)
    }

    @Test("a batch that finishes building after a reset is discarded, not installed")
    func discardsBatchBuiltBeforeReset() async throws {
        let queue = Self.makeQueue()
        let installs = CallCounter()

        await #expect(throws: CancellationError.self) {
            try await queue.next(
                buildBatch: {
                    // The location switch lands while the previous session is still building.
                    await queue.reset()
                    return [Self.configuration("old")]
                },
                authorize: { $0 },
                didInstall: { _ in await installs.increment() }
            )
        }
        #expect(await installs.count == 0)

        let next = try await queue.next(buildBatch: { [Self.configuration("new")] }, authorize: { $0 })
        #expect(Self.names(next) == "new")
    }

    @Test("a configuration that finishes authorizing after a reset is not handed out")
    func discardsConfigurationAuthorizedBeforeReset() async throws {
        let queue = Self.makeQueue()
        let source = BatchSource([
            [Self.configuration("old-1"), Self.configuration("old-2")],
            [Self.configuration("new")]
        ])

        await #expect(throws: CancellationError.self) {
            try await queue.next(
                buildBatch: { await source.build() },
                authorize: { configuration in
                    await queue.reset()
                    return configuration
                }
            )
        }

        let next = try await queue.next(buildBatch: { await source.build() }, authorize: { $0 })
        #expect(Self.names(next) == "new")
    }

    // MARK: Authorization

    private actor CallCounter {
        private(set) var count = 0
        func increment() { count += 1 }
    }

    private struct FakeWireGuardAuthenticator: PacketTunnelWireguardAuthenticator {
        let calls = CallCounter()

        func authenticate(config: WireguardEndpointConfiguration) async throws -> WireguardEndpointConfiguration {
            await calls.increment()
            var authenticated = config
            authenticated.serverPublicKey = "server-key"
            authenticated.clientPrivateKey = "client-key"
            authenticated.internalIp = "10.0.0.2"
            return authenticated
        }
    }

    /// Fails the test if it is ever asked to authenticate.
    private struct UnexpectedAuthenticator: PacketTunnelWireguardAuthenticator {
        func authenticate(config: WireguardEndpointConfiguration) async throws -> WireguardEndpointConfiguration {
            Issue.record("OpenVPN configurations must not go through the WireGuard authenticator")
            return config
        }
    }

    @Test("wireguard configurations go through the authenticator")
    func authorizesWireGuard() async throws {
        let authenticator = FakeWireGuardAuthenticator()
        let repository = PIAEndpointRepository(wireGuardAuthenticator: authenticator)
        let server = Server(
            serial: "1",
            name: "US Seattle",
            country: "US",
            hostname: "us-seattle.pvt.site",
            wireGuardAddressesForUDP: [Server.ServerAddressIP(ip: "1.1.1.1", cn: "wg-cn", van: true, port: nil)],
            pingAddress: nil,
            regionIdentifier: "us_seattle"
        )
        let configuration = try #require(
            repository.generateWireGuardConfigurations(server: server, state: PIATunnelSharedState.read()).first
        )

        let authorized = try await repository.authorize(configuration)

        // The SDK's `authorize` throws unless the keys and internal IP came back filled in.
        #expect(authorized is KapeWireGuardConfig)
        #expect(await authenticator.calls.count == 1)
    }

    @Test("openvpn configurations pass through untouched")
    func passesOpenVPNThrough() async throws {
        let repository = PIAEndpointRepository(wireGuardAuthenticator: UnexpectedAuthenticator())
        let configuration = OpenVPNConfiguration(
            host: "1.1.1.1",
            port: 1198,
            transport: .udp,
            ovpnConfiguration: "",
            ovpnConfigTemplate: nil,
            xorValue: nil,
            mtu: 1250,
            certDn: "ovpn-cn",
            username: "user",
            password: "pass",
            caCertificate: "ca",
            clientCertificate: "",
            clientKey: "",
            tlsAuthKey: "",
            appGroupIdentifier: "group.test"
        )

        let authorized = try await repository.authorize(configuration)

        let openVPN = try #require(authorized as? OpenVPNConfiguration)
        #expect(openVPN.username == "user")
        #expect(openVPN.host == "1.1.1.1")
    }
}

extension PIAEndpointRepository.ConfigurationQueue {
    /// For the tests that don't look at installs.
    fileprivate func next(
        buildBatch: @Sendable () async -> [any VpnConfiguration],
        authorize: @Sendable (any VpnConfiguration) async throws -> any VpnConfiguration
    ) async throws -> (any VpnConfiguration)? {
        try await next(buildBatch: buildBatch, authorize: authorize, didInstall: { _ in })
    }
}
