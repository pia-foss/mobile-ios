//
//  Client+Configuration.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
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
import Alamofire

extension Client {
    
    /// Encapsulates internal and public parameters of the client. When not specified otherwise, time intervals are in milliseconds.
    public final class Configuration {

        static let teamId = "5357M5NW9W"

        static let appGroup = "group.com.privateinternetaccess"

        static let debugLogKey = "LastVPNLog"
        
        /// If `true`, expose development features.
        public var isDevelopment: Bool
        
        // MARK: WebServices
        
        private var baseUrls: [Client.Environment: String]

        private let debugLogBaseUrls: [Client.Environment: String]

        var baseUrl: String {
            guard let url = baseUrls[Client.environment] else {
                fatalError("Base URL not found for environment \(Client.environment). Use setBaseURL(_:for:) to fix the issue.")
            }
            return url
        }

        let tosPath: String
        
        var tosUrl: String {
            return "\(baseUrl)/\(tosPath)"
        }
        
        let privacyPath: String
        
        var privacyUrl: String {
            return "\(baseUrl)/\(privacyPath)"
        }
        
        /// The timeout for web requests.
        public var webTimeout: Int
        
        // MARK: Server

        /// The JSON to load the initial `ServersBundle` from.
        ///
        /// - Seealso: `ServerProvider.load(...)`
        public var bundledServersJSON: Data?

        /// Downloads server updates regularly.
        public var enablesServerUpdates: Bool
        
        let defaultServersConfiguration: ServersBundle.Configuration

        /// Sets the delay after which to re-schedule servers update when network is down.
        public var serversUpdateWhenNetworkDownDelay: Int
        
        /// Verifies the servers signature after download.
        public var verifiesServersSignature: Bool

        /// Enables background server pinging.
        public var enablesServerPings: Bool
        
        /// Sets the interval before which pings are not repeated.
        public var minPingInterval: Int

        private(set) var customServers: [Server]
        
        // MARK: Connectivity

        /// Notifies connectivity updates e.g. current IP addresses.
        ///
        /// - Seealso: `Client.Daemons`
        public var enablesConnectivityUpdates: Bool

        let connectivityVPNLag: Int
        
        /// Sets the timeout for connectivity checks.
        public var connectivityTimeout: Int

        /// Sets the delay after which to retry connectivity checks.
        public var connectivityRetryDelay: Int
        
        /// Sets the maximum number of failed connectivity checks before giving up.
        public var connectivityMaxAttempts: Int
        
        /// Sets the timeout for VPN connectivity checks.
        public var vpnConnectivityTimeout: TimeInterval

        /// Sets the delay after which to retry VPN connectivity checks.
        public var vpnConnectivityRetryDelay: TimeInterval
        
        /// Sets the maximum number of failed VPN connectivity attempts before giving up.
        public var vpnConnectivityMaxAttempts: Int

        let maceHostname: String
        
        let macePort: UInt16

        let maceDelay: Int

        let sessionManager: SessionManager

        // MARK: VPN
        
        private var availableVPNProfiles: [VPNProfile]
        
        /// The name of the current VPN profile as seen in the iOS VPN settings.
        public var vpnProfileName: String

        /// The default delay of VPN reconnection attempts.
        public var vpnReconnectionDelay: Int
        
        #if os(iOS)
        
        // MARK: InApp
        
        private var inAppPlans: [String: Plan]
        
        /// Enables background server pinging.
        public var eligibleForTrial: Bool
        
        #endif
        
        /// The value of the max of servers appearing in the quick connect tile.
        public var maxQuickConnectServers: Int

        /// Store the account password in memory when the email is set and the user is LoggedIn.
        public var tempAccountPassword: String

        /// Enabled features
        public var featureFlags: [String]

        // MARK: Initialization
        
        init() {

            isDevelopment = false

            let production = "https://www.privateinternetaccess.com"
            baseUrls = [
                .production: production
            ]
            debugLogBaseUrls = [
                .production: production,
                .staging: production
            ]
            tosPath = "pages/terms-of-service"
            privacyPath = "pages/privacy-policy"

            webTimeout = 10000
            
            enablesServerUpdates = false
            defaultServersConfiguration = ServersBundle.Configuration(
                ovpnPorts: ServersBundle.Configuration.Ports(
                    udp: [8080],
                    tcp: [80]
                ),
                wgPorts: ServersBundle.Configuration.Ports(
                    udp: [1337],
                    tcp: []
                ),
                ikev2Ports: ServersBundle.Configuration.Ports(
                    udp: [500, 4500],
                    tcp: []
                ),
                latestVersion: 60,
                pollInterval: 600000,
                automaticIdentifiers: nil
            )
            serversUpdateWhenNetworkDownDelay = 10000
            verifiesServersSignature = true
            customServers = []

            enablesServerPings = false
            minPingInterval = 120000

            availableVPNProfiles = [IKEv2Profile()]
            vpnProfileName = "Private Internet Access"
            vpnReconnectionDelay = 2000
            
            enablesConnectivityUpdates = false
            connectivityVPNLag = 1000
            connectivityTimeout = 3000
            connectivityRetryDelay = 10000
            connectivityMaxAttempts = 3

            vpnConnectivityTimeout = 2.0
            vpnConnectivityRetryDelay = 5.0
            vpnConnectivityMaxAttempts = 3

            maceHostname = "209.222.18.222"
            macePort = 1111
            maceDelay = 5000

            let urlscfg = URLSessionConfiguration.default
            urlscfg.timeoutIntervalForRequest = Double(webTimeout) / 1000.0
            urlscfg.timeoutIntervalForResource = Double(webTimeout) / 1000.0
            urlscfg.urlCache = nil
            sessionManager = SessionManager(configuration: urlscfg)
            
            #if os(iOS)
            inAppPlans = [:]
            eligibleForTrial = true
            #endif
            
            maxQuickConnectServers = 6
            tempAccountPassword = ""

            featureFlags = []
        }
        
        // MARK: WebServices
        
        /**
         Sets base URL for web services in a determined environment.
         
         - Parameter url: The URL `String` to set.
         - Parameter environment: The target `Environment` to update.
         */
        public func setBaseURL(_ url: String, for environment: Environment) {
            baseUrls[environment] = url
        }
        
        // MARK: Server
        
        /**
         Inserts a custom server on top on the server list.

         - Parameter server: The server.
         */
        public func addCustomServer(_ server: Server) {
            customServers.append(server)
        }
        
        // MARK: VPN

        /**
         Adds a VPN profile to the globally available profiles.

         - Parameter profile: The `VPNProfile` to add.
         */
        public func addVPNProfile(_ profile: VPNProfile) {
            availableVPNProfiles.append(profile)
        }

        /**
         Returns the list of the available VPN profile types.
         
         - Returns: A list of unique strings associated with the available `VPNProfile` objects.
         - Seealso: `VPNProfile.vpnType`
         */
        public func availableVPNTypes() -> [String] {
            return availableVPNProfiles.map { $0.vpnType }
        }
        
        func profile(forVPNType type: String) -> VPNProfile? {
            return availableVPNProfiles.first { $0.vpnType == type }
        }
        
        /**
        Returns true if the purchase feature is available
         - Returns: A boolean indicating if purchases are available.
        */
        public func arePurchasesAvailable() -> Bool {
            if let url = Bundle.main.appStoreReceiptURL,
                url.lastPathComponent == "sandboxReceipt",
                Client.environment == .production {
                return false
            }
            return true
        }
        
        #if os(iOS)
        
        // MARK: InApp
        
        /**
         Defines the `Plan` that a product identifier is able to purchase.
         
         - Parameter plan: The `Plan` to associate with a product.
         - Parameter productIdentifier: The identifier of the in-app product.
         */
        public func setPlan(_ plan: Plan, forProductIdentifier productIdentifier: String) {
            inAppPlans[productIdentifier] = plan
        }
        
        func plan(forProductIdentifier productIdentifier: String) -> Plan? {
            return inAppPlans[productIdentifier]
        }
        
        func allProductIdentifiers() -> [String] {
            return [String](inAppPlans.keys)
        }
        
        #endif
        
//        public init(name: String) {
//            guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {
//                fatalError("Unable to read configuration from \(name).plist")
//            }
//            guard let dict = NSDictionary(contentsOfFile: path) else {
//                fatalError("Configuration file \(name).plist is malformed")
//            }
//
//            isDevelopment = dict["Development"] as! Bool
//
//            let ws = dict["WebServices"] as! [String: Any]
//            var baseUrls = [Client.Environment: String]()
//            for (envString, url) in ws["BaseURLs"] as! [String: String] {
//                guard let environment = Client.Environment(rawValue: envString) else {
//                    continue
//                }
//                baseUrls[environment] = url
//            }
//            self.baseUrls = baseUrls
//            clientRoot = ws["ClientRoot"] as! String
//
//            let iap = dict["InApp"] as! [String: String]
//            var inApps = [String: Plan]()
//            for (id, planString) in iap {
//                guard let plan = Plan(rawValue: planString) else {
//                    continue
//                }
//                inApps[id] = plan
//            }
//            self.inApps = inApps
//        }
    }
}
