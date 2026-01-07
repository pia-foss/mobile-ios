//
//  Bootstrapper.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/4/17.
//  Copyright © 2020 Private Internet Access, Inc.
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
#if canImport(TunnelKitCore)
import TunnelKitCore
import TunnelKitOpenVPN
import PIAWireguard
#endif
import UIKit
import Logging

extension NSNotification.Name {
    public static let __AppDidFetchForceUpdateFeatureFlag = Notification.Name("__AppDidFetchForceUpdateFeatureFlag")
}

class Bootstrapper {
    
    static let shared = Bootstrapper()
    
    private init() {
    }
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
  
    /// Update the values of the flags from the CSI server
    private func updateFeatureFlagsForReleaseIfNeeded() {
        // Some feature flags like Leak Protection are controled from the Developer menu on Dev builds.
        // So we skip updating the flag from the server on dev builds

        #if !STAGING
       // Leak Protection feature flags
        AppPreferences.shared.showLeakProtection = Client.configuration.featureFlags.contains(Client.FeatureFlags.showLeakProtection)
        AppPreferences.shared.showLeakProtectionNotifications = Client.configuration.featureFlags.contains(Client.FeatureFlags.showLeakProtectionNotifications)
        
        // DynamicIsland LiveActivity
        AppPreferences.shared.showDynamicIslandLiveActivity = Client.configuration.featureFlags.contains(Client.FeatureFlags.showDynamicIslandLiveActivity)
        #endif
    }

    func bootstrap() {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            
            #if STAGING
            handler.logLevel = .debug
            #else
            handler.logLevel = .info
            #endif
            
            return MultiplexLogHandler([
                handler,
                PIALogHandler(label: label)
            ])
        }

        // Load the database first
        Client.database = Client.Database(group: AppConstants.appGroup)
        
        // Check if should clean the account after delete the app and install again
        if Client.providers.accountProvider.shouldCleanAccount {
            //If first install, we need to ensure we don't have data from previous sessions in the Secure Keychain
            Client.providers.accountProvider.cleanDatabase()
        }

        AppPreferences.shared.migrate()
        AppPreferences.shared.migrateNMT()

        // PIALibrary
        #if os(iOS)
        guard let bundledRegionsURL = AppConstants.RegionsGEN4.bundleURL else {
            fatalError("Could not find bundled regions file")
        }
        let bundledServersJSON: Data
        do {
            try bundledServersJSON = Data(contentsOf: bundledRegionsURL)
        } catch let e {
            fatalError("Could not parse bundled regions file: \(e)")
        }
        #endif

        Client.configuration.rsa4096Certificate = rsa4096Certificate()

        #if STAGING
        Client.environment = .staging

        Client.configuration.isDevelopment = Flags.shared.usesDevelopmentClient
        if let stagingUrl = AppConstants.Web.stagingEndpointURL {
            if AppPreferences.shared.stagingVersion < 1 {
                Client.environment = .staging
                let stagingVersion = Int(stagingUrl.absoluteString.split(separator: "-")[1]) ?? 1
                AppPreferences.shared.stagingVersion = stagingVersion
            }

            let url = stagingUrl.absoluteString.replacingOccurrences(of: "staging-[0-9]", with: "staging-\(AppPreferences.shared.stagingVersion)", options: .regularExpression)
            Client.configuration.setBaseURL(url, for: .staging)
        }

        if Client.configuration.isDevelopment, let customServers = AppConstants.Servers.customServers {
            for server in customServers {
                Client.configuration.addCustomServer(server)
            }
        }
        #else
        Client.environment = .production
        #endif
        
        Client.configuration.enablesConnectivityUpdates = true
        Client.configuration.enablesServerUpdates = true
        Client.configuration.enablesServerPings = true
    #if os(iOS)
        Client.configuration.bundledServersJSON = bundledServersJSON
    #endif
        Client.configuration.webTimeout = AppConfiguration.ClientConfiguration.webTimeout
        Client.configuration.vpnProfileName = AppConfiguration.VPN.profileName
    #if os(iOS)
        Client.configuration.addVPNProfile(IKEv2Profile())
        Client.configuration.addVPNProfile(PIATunnelProfile(bundleIdentifier: AppConstants.Extensions.tunnelBundleIdentifier))
        Client.configuration.addVPNProfile(PIAWGTunnelProfile(bundleIdentifier: AppConstants.Extensions.tunnelWireguardBundleIdentifier))
    #endif
        let defaults = Client.preferences.defaults
        defaults.isPersistentConnection = true
        defaults.mace = false
    #if os(iOS)
        defaults.vpnCustomConfigurations = [
            PIATunnelProfile.vpnType: AppConfiguration.VPN.piaDefaultConfigurationBuilder.build(),
            PIAWGTunnelProfile.vpnType: PIAWireguardConfiguration(customDNSServers: [], packetSize: AppConstants.WireGuardPacketSize.defaultPacketSize)
        ]
    #endif
        
        if Client.preferences.shareServiceQualityData {
            ServiceQualityManager.shared.start()
        } else {
            ServiceQualityManager.shared.stop()
        }

        Client.providers.accountProvider.featureFlags({ _ in
            AppPreferences.shared.checksDipExpirationRequest = Client.configuration.featureFlags.contains(Client.FeatureFlags.checkDipExpirationRequest)
            AppPreferences.shared.disablesMultiDipTokens = Client.configuration.featureFlags.contains(Client.FeatureFlags.disableMultiDipTokens)
            AppPreferences.shared.showNewInitialScreen = Client.configuration.featureFlags.contains(Client.FeatureFlags.showNewInitialScreen)


            /// Updates the feature flags values to the ones set on the server only on Release builds.
            /// (like Leak protection feature)
            self.updateFeatureFlagsForReleaseIfNeeded()
            
            self.checkForceUpdateIfNeeded()
        })

        //FORCE THE MIGRATION TO GEN4
    #if os(iOS)
        if Client.providers.vpnProvider.needsMigrationToGEN4() {

            Client.preferences.displayedServer = Server.automatic
            NotificationCenter.default.post(name: .PIAThemeDidChange,
                                            object: self,
                                            userInfo: nil)
            Client.providers.vpnProvider.reconnect(after: 200, forceDisconnect: true, { _ in
            })
        }
    #endif
        Client.providers.accountProvider.subscriptionInformation { [weak self] (info, error) in
            
            if let _ = error {
                self?.setDefaultPlanProducts()
            }
            
            if let info = info {
            
                if info.products.count > 0 {
                    for product in info.products {
                        if !product.legacy {
                            Client.configuration.setPlan(product.plan, forProductIdentifier: product.identifier)
                        }
                    }
                }

            }

            Client.refreshProducts()
            Client.observeTransactions()
        }

        if (self.isSimulator || Flags.shared.usesMockVPN) {
            Client.configuration.enablesConnectivityUpdates = false
            Client.useMockVPNProvider()
        }
        if Flags.shared.usesMockInApp {
            Client.useMockInAppProvider()
        }
        if Flags.shared.usesMockAccount {
            Client.useMockAccountProvider(AppConfiguration.Mock.accountProvider)
        }

        Client.bootstrap()

        // Configurations

        RatingManager.shared.loadInAppRatingConfig()
        
        // Preferences
        
        let pref = Client.preferences.editable()
        
        // as per App Store guidelines
        if !Flags.shared.enablesMACESetting {
            pref.mace = false
        }
        
        pref.commit()
        #if os(iOS)
        AppPreferences.shared.migrateOVPN()
        AppPreferences.shared.migrateWireguard()
        
        // Business objects
        
        AccountObserver.shared.start()
        //        DataCounter.shared.startCounting()
        #endif
        // Notifications
        
        let nc = NotificationCenter.default
        #if os(iOS)
        nc.addObserver(self, selector: #selector(reloadTheme), name: .PIAThemeDidChange, object: nil)
        #endif
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        nc.addObserver(self, selector: #selector(internetUnreachable(notification:)), name: .ConnectivityDaemonDidGetUnreachable, object: nil)
        nc.addObserver(self, selector: #selector(internetReachable(notification:)), name: .ConnectivityDaemonDidGetReachable, object: nil)
        
        // PIALibrary (Theme)
        #if os(iOS)
        AppPreferences.shared.currentThemeCode.apply(theme: Theme.current, reload: true)
        #endif
        
        // show walkthrough on upgrade except for logged in users
        if Client.providers.accountProvider.isLoggedIn {
            AppPreferences.shared.wasLaunched = true
        }
        
        // Check the DIP token for renewal
        if AppPreferences.shared.checksDipExpirationRequest, let dipToken = Client.providers.serverProvider.dipTokens?.first {
            Client.providers.serverProvider.handleDIPTokenExpiration(dipToken: dipToken, nil)
        }
        setupExceptionHandler()
    }
    
    private func setDefaultPlanProducts() {
        Client.configuration.setPlan(.yearly, forProductIdentifier: AppConstants.InApp.yearlyProductIdentifier)
        Client.configuration.setPlan(.monthly, forProductIdentifier: AppConstants.InApp.monthlyProductIdentifier)
    }

    func dispose() {
        Client.dispose()
    }
    
    private func setupExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            Client.preferences.lastKnownException = "$exception,\n\(exception.callStackSymbols.joined(separator: "\n"))"
        }
    }
    
    // MARK: Certificate

    func rsa4096Certificate() -> String? {
        #if os(iOS)
        return AppPreferences.shared.piaHandshake.pemString()
        #else
        // FIXME: Implement for tvOS
        return nil
        #endif
    }
    
    // MARK: Notifications
#if os(iOS)
    @objc private func reloadTheme() {
        Theme.current.applySideMenu()
        Theme.current.applyAppearance()
    }
#endif
    @objc private func vpnStatusDidChange(notification: Notification) {
        let vpnStatus = Client.providers.vpnProvider.vpnStatus
        switch vpnStatus {
        case .connected:
            AppPreferences.shared.incrementSuccessConnections()
        case .disconnected:
            AppPreferences.shared.incrementSuccessDisconnections()
        default:
            break
        }
        #if os(iOS)
        RatingManager.shared.handleConnectionStatusChanged()
        #endif
    }
    
    @objc private func internetReachable(notification: Notification) {
        #if os(iOS)
        Macros.removeStickyNote()
        #endif
    }
    
    @objc private func internetUnreachable(notification: Notification) {
        #if os(iOS)
        Macros.displayStickyNote(withMessage: L10n.Localizable.Global.unreachable,
                                 andImage: Asset.Images.iconWarning.image)
        #endif
    }
}

extension Bootstrapper {
    func checkForceUpdateIfNeeded() {
        if Client.configuration.featureFlags.contains("force_update") {
            NotificationCenter.default.post(name: Notification.Name.__AppDidFetchForceUpdateFeatureFlag, object: nil)
        }
    }
}
