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

    private static var platformSDKMigration: PlatformSDKMigrationUseCaseType {
        PlatformSDKMigrationFactory.makePlatformSDKMigrationUseCase
    }

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
        // tvOS connects through the PlatformSDK tunnel (registered in `setupConfiguration`), and the
        // user's `vpnType` selects which protocol that tunnel runs (see the Protocol settings
        // screen): "PIAAutomatic" → automatic (default, WireGuard then OpenVPN), "PIAWG" →
        // WireGuard, "PIA" → OpenVPN.
        //
        // This no longer depends on the migration having been consented to: there is no legacy
        // IKEv2 profile left to fall back to, so automatic is the only sensible default either way.
        defaults.vpnType = KapePlatformSDKVPNType.automatic.rawValue
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

        // The PlatformSDK profile is the only profile now, so it is registered unconditionally —
        // there is no legacy IKEv2 profile to register instead while the user has yet to consent.
        // Consent still gates the *prune*, which is the disruptive part the migration screen warns
        // about; `cleanupLegacyVPNProfilesIfNeeded` checks it internally.
        Client.configuration.addVPNProfile(
            KapePlatformSDKTunnelProfile(
                bundleIdentifier: AppConstants.Extensions.tunnelPlatformSDKTvOSBundleIdentifier
            )
        )
        platformSDKMigration.cleanupLegacyVPNProfilesIfNeeded()
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
