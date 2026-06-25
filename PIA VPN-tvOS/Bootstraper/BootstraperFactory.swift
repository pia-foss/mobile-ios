//
//  BootstraperFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Logging
import PIALibrary

class BootstraperFactory {
    static func makeBootstrapper() -> BootstraperType {
        Bootstrapper(
            setupEnvironment: setupEnvironment,
            setupDebuggingConsole: setupDebuggingConsole,
            loadDataBase: loadDataBase,
            cleanCurrentAccount: cleanCurrentAccount,
            migrateNMT: migrateNMT,
            setupLatestRegionList: setupLatestRegionList,
            setupConfiguration: setupConfiguration,
            setupPreferences: setupPreferences,
            acceptDataSharing: acceptDataSharing,
            dependencyBootstrap: Client.bootstrap,
            renewalDIPToken: renewalDIPToken,
            setupExceptionHandler: setupExceptionHandler,
            startConnectionStateMonitor: startConnectionStateMonitor,
            startCachingLicenses: startCachingLicenses
        )
    }

    private static func setupEnvironment() {
        #if STAGING
            Client.environment = .staging
            Client.configuration.setBaseURL(Macros.baseUrl(), for: .staging)
        #else
            Client.environment = .production
            Client.configuration.setBaseURL(Macros.baseUrl(), for: .production)
        #endif
    }

    private static func setupDebuggingConsole() {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)

            #if DEVELOPMENT || STAGING
                handler.logLevel = .debug
            #else
                handler.logLevel = .info
            #endif

            return MultiplexLogHandler([
                handler,
                PIALogHandler(label: label)
            ])
        }
    }

    private static func migrateNMT() {
        AppPreferences.shared.migrateNMT()
    }

    private static func loadDataBase() {
        Client.database = Client.Database(group: AppConstants.appGroup)
        Client.providers.serverProvider = ServerProviderFactory.makeDefaultServerProvider()

        // Force enable debug logging for DEVELOPMENT and STAGING builds
        #if DEVELOPMENT || STAGING
            Client.preferences.debugLogging = true
        #endif
    }

    private static func setupPreferences() {
        let defaults = Client.preferences.defaults
        defaults.isPersistentConnection = true
        defaults.mace = false
        // The default protocol depends on whether VPN runs through the PlatformSDK tunnel.
        // When the flag is on, tvOS connects through the PlatformSDK tunnel (registered in
        // `setupConfiguration`) and the user's `vpnType` selects which protocol the tunnel runs
        // (see the Protocol settings screen): "PIAWG" → WireGuard (default), "PIA" → OpenVPN.
        // The literals mirror `PIAWGTunnelProfile`/`PIATunnelProfile`, which are iOS-only and not
        // linkable on tvOS. When the flag is off, tvOS keeps the legacy IKEv2 profile, so the
        // default must be IKEv2 — otherwise `resolvedActiveProfile()` can't match a profile.
        defaults.vpnType = Client.configuration.featureFlags[.usePlatformSDKVPN] ? "PIAWG" : IKEv2Profile.vpnType
    }

    private static func cleanCurrentAccount() {
        // Check if should clean the account after delete the app and install again
        if Client.providers.accountProvider.shouldCleanAccount {
            //If first install, we need to ensure we don't have data from previous sessions in the Secure Keychain
            Client.providers.accountProvider.cleanDatabase()
        }
    }

    private static func setupLatestRegionList() {
        guard let bundledRegionsURL = AppConstants.RegionsGEN4.bundleURL else {
            fatalError("Could not find bundled regions file")
        }

        do {
            let bundledServersJSON = try Data(contentsOf: bundledRegionsURL)
            Client.configuration.bundledServersJSON = bundledServersJSON
        } catch let e {
            fatalError("Could not parse bundled regions file: \(e)")
        }
    }

    private static func renewalDIPToken() {
        // Check the DIP token for renewal
        if AppPreferences.shared.checksDipExpirationRequest, let dipToken = Client.providers.serverProvider.dipTokens?.first {
            Client.providers.serverProvider.handleDIPTokenExpiration(dipToken: dipToken, nil)
        }
    }

    private static func setupConfiguration() {
        Client.configuration.enablesConnectivityUpdates = true
        Client.configuration.enablesServerUpdates = true
        Client.configuration.enablesServerPings = true
        Client.configuration.webTimeout = AppConfiguration.ClientConfiguration.webTimeout
        Client.configuration.vpnProfileName = AppConfiguration.VPN.profileName
        Client.configuration.rsa4096Certificate = Client.Configuration.defaultRSACertificate()

        if Client.configuration.featureFlags[.usePlatformSDKVPN] {
            Client.configuration.addVPNProfile(
                KapePlatformSDKTunnelProfile(
                    bundleIdentifier: AppConstants.Extensions.tunnelPlatformSDKTvOSBundleIdentifier
                )
            )
            cleanupLegacyVPNProfilesIfNeeded()
        } else {
            Client.configuration.addVPNProfile(IKEv2Profile())
        }
    }

    /// One-time removal of the legacy IKEv2 VPN configuration after migrating to the PlatformSDK
    /// tunnel. tvOS only ever shipped IKEv2 (no OpenVPN/WireGuard tunnels), so that is the single
    /// legacy profile to clear. Without this, an IKEv2 Network Extension config left over from
    /// before the flag was enabled — possibly with on-demand active — could auto-start the old
    /// tunnel alongside the PlatformSDK profile.
    private static func cleanupLegacyVPNProfilesIfNeeded() {
        guard Client.configuration.featureFlags[.usePlatformSDKVPN],
            !AppPreferences.shared.didCleanupLegacyVPNProfiles
        else {
            return
        }

        let legacyProfile = IKEv2Profile()
        legacyProfile.disconnect { _ in
            legacyProfile.remove { _ in
                AppPreferences.shared.didCleanupLegacyVPNProfiles = true
            }
        }
    }

    private static func acceptDataSharing() {
        let connectionStatsPermisson = ConnectionStatsPermisson()
        guard let permissionGranted = connectionStatsPermisson.get(),
            permissionGranted
        else {
            ServiceQualityManager.shared.stop()
            return
        }

        ServiceQualityManager.shared.start()
    }

    private static func setupExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            let stackTrace = exception.callStackSymbols.joined(separator: "\n")
            Client.preferences.lastKnownException = "Exception: \(exception.name.rawValue)\nReason: \(exception.reason ?? "Unknown")\nStack:\n\(stackTrace)"
        }
    }

    private static func startCachingLicenses() {
        HelpFactory.makeLicensesUseCase()
    }

    private static func startConnectionStateMonitor() {
        StateMonitorsFactory.makeConnectionStateMonitor()
    }

}
