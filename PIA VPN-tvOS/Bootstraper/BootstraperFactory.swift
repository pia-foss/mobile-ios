//
//  BootstraperFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import SwiftyBeaver

class BootstraperFactory {
    static func makeBootstrapper() -> BootstraperType {
        if let stagingUrl = AppConstants.Web.stagingEndpointURL {
            if AppPreferences.shared.stagingVersion < 1 {
                Client.environment = .staging
                let stagingVersion = Int(stagingUrl.absoluteString.split(separator: "-")[1]) ?? 1
                AppPreferences.shared.stagingVersion = stagingVersion
            }
                    
            let url = stagingUrl.absoluteString.replacingOccurrences(of: "staging-[0-9]", with: "staging-\(AppPreferences.shared.stagingVersion)", options: .regularExpression)
            Client.configuration.setBaseURL(url, for: .staging)

        }
                
        Client.environment = .staging
        return Bootstrapper(
            setupDebugginConsole: setupDebugginConsole,
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
    
    private static func setupDebugginConsole() {
        let console = ConsoleDestination()
        #if PIA_DEV
        console.minLevel = .debug
        #else
        console.minLevel = .info
        #endif
        SwiftyBeaver.addDestination(console)
    }
    
    private static func migrateNMT() {
        AppPreferences.shared.migrateNMT()
    }
    
    private static func loadDataBase() {
        Client.database = Client.Database(group: AppConstants.appGroup)
    }
    
    private static func setupPreferences() {
        let defaults = Client.preferences.defaults
        defaults.isPersistentConnection = true
        defaults.mace = false
        defaults.vpnType = IKEv2Profile.vpnType
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
    }
    
    private static func acceptDataSharing() {
        let connectionStatsPermisson = ConnectionStatsPermisson()
        guard let permissionGranted = connectionStatsPermisson.get(),
        permissionGranted else {
            ServiceQualityManager.shared.stop()
            return
        }
        
        ServiceQualityManager.shared.start()
    }
    
    private static func setupExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            Client.preferences.lastKnownException = "$exception,\n\(exception.callStackSymbols.joined(separator: "\n"))"
        }
    }
    
    
    private static func startCachingLicenses() {
        HelpFactory.makeLicensesUseCase()
    }
    
    private static func startConnectionStateMonitor() {
        StateMonitorsFactory.makeConnectionStateMonitor()
    }
    
}
