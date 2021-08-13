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
import TunnelKit
import SwiftyBeaver
import PIAWireguard
#if PIA_DEV
import Firebase
import Fabric
import Crashlytics
#endif

class Bootstrapper {
    
    static let shared = Bootstrapper()
    
    private init() {
    }
    
    private var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }

    func bootstrap() {
        let console = ConsoleDestination()
        #if PIA_DEV
        console.minLevel = .debug
        
        if let path = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"),
            let plist = NSDictionary(contentsOf: path) as? [String: Any],
            plist.count > 0 {
            FirebaseApp.configure()
            Fabric.sharedSDK().debug = true
            Fabric.with([Crashlytics.self()])
        }
        #else
        console.minLevel = .info
        #endif
        SwiftyBeaver.addDestination(console)

        // Load the database first
        Client.database = Client.Database(team: AppConstants.teamId, group: AppConstants.appGroup)
        
        // Check if should clean the account after delete the app and install again
        if Client.providers.accountProvider.shouldCleanAccount {
            //If first install, we need to ensure we don't have data from previous sessions in the Secure Keychain
            Client.providers.accountProvider.cleanDatabase()
        }

        AppPreferences.shared.migrate()
        AppPreferences.shared.migrateNMT()

        // PIALibrary
        
        guard let bundledRegionsURL = AppConstants.RegionsGEN4.bundleURL else {
            fatalError("Could not find bundled regions file")
        }
        let bundledServersJSON: Data
        do {
            try bundledServersJSON = Data(contentsOf: bundledRegionsURL)
        } catch let e {
            fatalError("Could not parse bundled regions file: \(e)")
        }

        Client.configuration.rsa4096Certificate = rsa4096Certificate()

        #if PIA_DEV
        Client.environment =  AppPreferences.shared.appEnvironmentIsProduction ? .production : .staging
        #else
        Client.environment =  AppConfiguration.clientEnvironment
        #endif
        Client.configuration.isDevelopment = Flags.shared.usesDevelopmentClient
        if let stagingUrl = AppConstants.Web.stagingEndpointURL {
            
            let url = stagingUrl.absoluteString.replacingOccurrences(of: "staging-[0-9]", with: "staging-\(AppPreferences.shared.stagingVersion)", options: .regularExpression)
            Client.configuration.setBaseURL(url, for: .staging)

        }
        if Client.configuration.isDevelopment, let customServers = AppConstants.Servers.customServers {
            for server in customServers {
                Client.configuration.addCustomServer(server)
            }
        }
        
        Client.configuration.enablesConnectivityUpdates = true
        Client.configuration.enablesServerUpdates = true
        Client.configuration.enablesServerPings = true
        Client.configuration.bundledServersJSON = bundledServersJSON
        Client.configuration.webTimeout = AppConfiguration.ClientConfiguration.webTimeout
        Client.configuration.vpnProfileName = AppConfiguration.VPN.profileName
        Client.configuration.addVPNProfile(PIATunnelProfile(bundleIdentifier: AppConstants.Extensions.tunnelBundleIdentifier))
        Client.configuration.addVPNProfile(PIAWGTunnelProfile(bundleIdentifier: AppConstants.Extensions.tunnelWireguardBundleIdentifier))

        let defaults = Client.preferences.defaults
        defaults.isPersistentConnection = true
        defaults.mace = false
        defaults.vpnType = IKEv2Profile.vpnType
        defaults.vpnCustomConfigurations = [
            PIATunnelProfile.vpnType: AppConfiguration.VPN.piaDefaultConfigurationBuilder.build(),
            PIAWGTunnelProfile.vpnType: PIAWireguardConfiguration(customDNSServers: [], packetSize: AppConstants.WireGuardPacketSize.defaultPacketSize)
        ]
        
        Client.providers.accountProvider.featureFlags({ _ in
            AppPreferences.shared.showsDedicatedIPView = Client.configuration.featureFlags.contains(Client.FeatureFlags.dedicatedIp)
            AppPreferences.shared.checksDipExpirationRequest = Client.configuration.featureFlags.contains(Client.FeatureFlags.checkDipExpirationRequest)
            AppPreferences.shared.disablesMultiDipTokens = Client.configuration.featureFlags.contains(Client.FeatureFlags.disableMultiDipTokens)
            
            if !Client.configuration.featureFlags.contains(Client.FeatureFlags.shareServiceQualityData) {
                let preferences = Client.preferences.editable()
                preferences.shareServiceQualityData = false
                preferences.commit()
            } else {
                if Client.preferences.shareServiceQualityData {
                    ServiceQualityManager.shared.start()
                } else {
                    ServiceQualityManager.shared.stop()
                }
            }
        })
        MessagesManager.shared.refreshMessages()

        //FORCE THE MIGRATION TO GEN4
        if Client.providers.vpnProvider.needsMigrationToGEN4() {

            Client.preferences.displayedServer = Server.automatic
            NotificationCenter.default.post(name: .PIAThemeDidChange,
                                            object: self,
                                            userInfo: nil)
            Client.providers.vpnProvider.reconnect(after: 200, forceDisconnect: true, { _ in
            })
        }
        
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
        
        // Preferences
        
        let pref = Client.preferences.editable()
        
        // as per App Store guidelines
        if !Flags.shared.enablesMACESetting {
            pref.mace = false
        }
        
        pref.commit()
        
        AppPreferences.shared.migrateOVPN()

        // Business objects
        
        AccountObserver.shared.start()
        //        DataCounter.shared.startCounting()
                
        // Notifications
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(reloadTheme), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        nc.addObserver(self, selector: #selector(internetUnreachable(notification:)), name: .ConnectivityDaemonDidGetUnreachable, object: nil)
        nc.addObserver(self, selector: #selector(internetReachable(notification:)), name: .ConnectivityDaemonDidGetReachable, object: nil)
        
        // PIALibrary (Theme)
        
        AppPreferences.shared.currentThemeCode.apply(theme: Theme.current, reload: true)
        
        // show walkthrough on upgrade except for logged in users
        if Client.providers.accountProvider.isLoggedIn {
            AppPreferences.shared.wasLaunched = true
        }
        
        // Check the DIP token for renewal
        if AppPreferences.shared.checksDipExpirationRequest, let dipToken = Client.providers.serverProvider.dipTokens?.first {
            Client.providers.serverProvider.handleDIPTokenExpiration(dipToken: dipToken, nil)
        }

    }
    
    private func setDefaultPlanProducts() {
        Client.configuration.setPlan(.yearly, forProductIdentifier: AppConstants.InApp.yearlyProductIdentifier)
        Client.configuration.setPlan(.monthly, forProductIdentifier: AppConstants.InApp.monthlyProductIdentifier)
    }

    func dispose() {
        Client.dispose()
    }

    // MARK: Certificate

    func rsa4096Certificate() -> String? {
        return AppPreferences.shared.piaHandshake.pemString()
    }
    
    // MARK: Notifications

    @objc private func reloadTheme() {
        Theme.current.applySideMenu()
        Theme.current.applyAppearance()
    }
    
    @objc private func vpnStatusDidChange(notification: Notification) {
        guard (Client.providers.vpnProvider.vpnStatus == .connected) else {
            return
        }
        RatingManager.shared.logSuccessConnection()
    }
    
    @objc private func internetReachable(notification: Notification) {
        Macros.removeStickyNote()
    }
    
    @objc private func internetUnreachable(notification: Notification) {
        Macros.displayStickyNote(withMessage: L10n.Global.unreachable,
                                 andImage: Asset.iconWarning.image)
    }
}
