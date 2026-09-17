//
//  TunnelProfileOwnershipTests.swift
//  PIALibraryTests
//

#if os(iOS)

    import NetworkExtension
    import XCTest

    @testable import PIALibrary

    /// `VPNDaemon.tryUpdateStatus` drops every `.NEVPNStatusDidChange` whose manager the active
    /// profile does not recognise. It used to recognise only the exact object currently held in
    /// `native`, which any `find()` replaces — so an unrelated lookup landing between the start of
    /// a tunnel and its first status change silenced the daemon for the rest of the session: the
    /// app stayed on `.disconnected` while the tunnel was really connecting, and every Connect tap
    /// was swallowed by the in-place `switchLocation` branch.
    final class TunnelProfileOwnershipTests: XCTestCase {

        private static let ourBundleIdentifier =
            "com.privateinternetaccess.ios.PIA-VPN.PlatformSDK-Tunnel-iOS"
        private static let legacyBundleIdentifier =
            "com.privateinternetaccess.ios.PIA-VPN.PIATunnel"

        private func makeProfile() -> KapePlatformSDKTunnelProfile {
            return KapePlatformSDKTunnelProfile(bundleIdentifier: Self.ourBundleIdentifier)
        }

        /// Mirrors what `loadAllFromPreferences` hands back: a distinct manager object each time,
        /// carrying the provider bundle identifier of the configuration it represents.
        private func makeManager(providerBundleIdentifier: String?) -> NETunnelProviderManager {
            let manager = NETunnelProviderManager()
            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.providerBundleIdentifier = providerBundleIdentifier
            tunnelProtocol.serverAddress = ""
            manager.protocolConfiguration = tunnelProtocol
            return manager
        }

        func testOwnsAManagerCarryingItsOwnProviderBundleIdentifier() {
            let profile = makeProfile()
            let manager = makeManager(providerBundleIdentifier: Self.ourBundleIdentifier)

            XCTAssertTrue(profile.owns(manager))
        }

        func testDoesNotOwnAManagerFromAnotherProvider() {
            let profile = makeProfile()
            let legacy = makeManager(providerBundleIdentifier: Self.legacyBundleIdentifier)

            XCTAssertFalse(
                profile.owns(legacy),
                "a legacy configuration being torn down after an upgrade must not drive our status")
        }

        func testDoesNotOwnAManagerWithNoProviderConfiguration() {
            let profile = makeProfile()

            XCTAssertFalse(profile.owns(NETunnelProviderManager()))
        }

        /// The live tunnel stays ours after an unrelated lookup has moved `native`.
        ///
        /// This is the exact shape of the bug: the dashboard's usage tile polls `requestDataUsage`
        /// on every status change, and that lookup used to rebind `native` to a *different*
        /// instance of the very same configuration.
        func testOwnershipSurvivesNativeBeingReboundByAnUnrelatedLookup() {
            let profile = makeProfile()
            let liveTunnel = makeManager(providerBundleIdentifier: Self.ourBundleIdentifier)
            profile.native = liveTunnel

            XCTAssertTrue(profile.owns(liveTunnel))

            // An unrelated lookup completes and rebinds `native`.
            let reloaded = makeManager(providerBundleIdentifier: Self.ourBundleIdentifier)
            profile.native = reloaded

            XCTAssertFalse(
                liveTunnel === (profile.native as? NETunnelProviderManager),
                "precondition: the rebind must produce a different object, "
                    + "otherwise this no longer reproduces the original failure")
            XCTAssertTrue(
                profile.owns(liveTunnel),
                "status changes from the live tunnel must still be recognised after `native` moved")
        }
    }

#endif
