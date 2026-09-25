//
//  NetworkExtensionProfileSaveTests.swift
//  PIALibraryTests
//
//  Regression coverage for KM-17626.
//

#if os(iOS)

    import Logging
    import NetworkExtension
    import XCTest

    @testable import PIALibrary

    final class NetworkExtensionProfileSaveTests: XCTestCase {

        private static var didBootstrapLogging = false

        // Mirrors the Release branch of Bootstrapper.bootstrap(), which lands on an
        // effective level of .debug and so evaluates .debug autoclosures.
        private func bootstrapShippingReleaseLogging() {
            guard !Self.didBootstrapLogging else { return }
            Self.didBootstrapLogging = true

            LoggingSystem.bootstrap { label in
                var handler = StreamLogHandler.standardOutput(label: label)
                handler.logLevel = .info
                return MultiplexLogHandler([handler, PIALogHandler(label: label)])
            }

            XCTAssertEqual(
                Logger(label: "probe").logLevel, .debug,
                "the shipping stack must still evaluate .debug autoclosures, "
                    + "otherwise this no longer reproduces the original crash")
        }

        private func makeSubject(
            publicUsername: String?
        ) -> (KapePlatformSDKTunnelProfile, NETunnelProviderManager, VPNConfiguration) {
            Client.database = Client.Database(group: "group.com.privateinternetaccess")
            Client.providers.vpnProvider = MockVPNProvider()

            let account = EphemeralAccountProvider()
            account.isLoggedIn = true
            account.vpnToken = "USER:PASS"
            account.vpnTokenUsername = "USER"
            account.publicUsername = publicUsername
            Client.providers.accountProvider = account

            Client.bootstrap()

            let server = Server(
                serial: "serial-1",
                name: "Server 1",
                country: "us",
                hostname: "server1.example.com",
                iKEv2AddressesForUDP: [Server.ServerAddressIP(ip: "10.0.0.1", cn: "cn", van: false)],
                pingAddress: nil,
                regionIdentifier: "region-1"
            )

            let configuration = VPNConfiguration(
                name: "PIA",
                username: "",
                passwordReference: Data(),
                server: server,
                isOnDemand: false,
                disconnectsOnSleep: false,
                leakProtection: false,
                allowLocalDeviceAccess: false
            )

            let profile = KapePlatformSDKTunnelProfile(
                bundleIdentifier: "com.privateinternetaccess.ios.PIA-VPN.PlatformSDK-Tunnel-iOS")

            return (profile, NETunnelProviderManager(), configuration)
        }

        /// The PlatformSDK tunnel carries neither credentials nor an endpoint in its `NEVPNProtocol`
        /// — the extension reads both from `PIATunnelSharedState` — so the username and
        /// server-address assertions the legacy WireGuard profile needed no longer apply. What still
        /// matters is that the protocol names the extension to launch.
        func testGeneratedProtocolTargetsTheTunnelExtension() {
            let (profile, _, configuration) = makeSubject(publicUsername: nil)

            let cfg = profile.generatedProtocol(withConfiguration: configuration)

            XCTAssertEqual(
                (cfg as? NETunnelProviderProtocol)?.providerBundleIdentifier,
                "com.privateinternetaccess.ios.PIA-VPN.PlatformSDK-Tunnel-iOS")
        }

        // Reaching the callback is the assertion: a regression traps at
        // NetworkExtensionProfile.swift:113 and takes the test process down.
        func testDoSaveSurvivesAnAccountWithoutAPublicUsername() {
            bootstrapShippingReleaseLogging()
            let (profile, vpn, configuration) = makeSubject(publicUsername: nil)

            let done = expectation(description: "doSave called back")
            profile.doSave(vpn, withConfiguration: configuration, force: true) { _ in
                done.fulfill()
            }
            wait(for: [done], timeout: 10)
        }
    }

#endif
