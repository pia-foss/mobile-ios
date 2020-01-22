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
import iRate
#if PIA_DEV
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
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
        
        MSAppCenter.start(AppConstants.appCenterAppId,
                        withServices: [MSAnalytics.self,
                                       MSCrashes.self])
        
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

        // PIALibrary
        
        guard let bundledRegionsURL = AppConstants.Regions.bundleURL else {
            fatalError("Could not find bundled regions file")
        }
        let bundledServersJSON: Data
        do {
            try bundledServersJSON = Data(contentsOf: bundledRegionsURL)
        } catch let e {
            fatalError("Could not parse bundled regions file: \(e)")
        }

        Client.environment = AppConfiguration.clientEnvironment
        Client.configuration.isDevelopment = Flags.shared.usesDevelopmentClient
        if let stagingUrl = AppConstants.Web.stagingEndpointURL {
            Client.configuration.setBaseURL(stagingUrl.absoluteString, for: .staging)
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
        
        let defaults = Client.preferences.defaults
        defaults.isPersistentConnection = true
        defaults.mace = false
        defaults.vpnType = IKEv2Profile.vpnType
        defaults.vpnCustomConfigurations = [
            PIATunnelProfile.vpnType: AppConfiguration.VPN.piaDefaultConfigurationBuilder.build()
        ]
        
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
        
        // Business objects
        
        AccountObserver.shared.start()
        //        DataCounter.shared.startCounting()
        
        // Third parties
        
        let rater = iRate.sharedInstance()!
        rater.usesUntilPrompt = AppConfiguration.Rating.usesUntilPrompt
        rater.eventsUntilPrompt = AppConfiguration.Rating.eventsUntilPrompt
        rater.daysUntilPrompt = AppConfiguration.Rating.daysUntilPrompt
        rater.remindPeriod = AppConfiguration.Rating.remindPeriod
        
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

    }
    
    private func setDefaultPlanProducts() {
        Client.configuration.setPlan(.yearly, forProductIdentifier: AppConstants.InApp.yearlyProductIdentifier)
        Client.configuration.setPlan(.monthly, forProductIdentifier: AppConstants.InApp.monthlyProductIdentifier)
    }

    func dispose() {
        Client.dispose()
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
        iRate.sharedInstance()!.logEvent(false)
    }
    
    @objc private func internetReachable(notification: Notification) {
        Macros.removeStickyNote()
    }
    
    @objc private func internetUnreachable(notification: Notification) {
        Macros.displayStickyNote(withMessage: L10n.Global.unreachable,
                                 andImage: Asset.iconWarning.image)
    }
}
