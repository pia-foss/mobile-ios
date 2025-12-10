//
//  Client.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
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
import SwiftyBeaver
import UIKit

private let log = SwiftyBeaver.self

/// The entry point for client initialization and usage.
@available(tvOS 17.0, *)
public final class Client {

    // MARK: Strategies

    /// The environment in which the client is currently running in.
    public static var environment: Environment = .production
    
    /// The global client configuration.
    public static let configuration = Client.Configuration()
    
    /// The persistence layer (customizable)
    public static var database = Client.Database()
    
    /// The current state of the background operations.
    public static let daemons = Client.Daemons()
    
    /// The library preferences.
    public static let preferences = Client.Preferences()
    
    /// The business providers (customizable).
    public static var providers = Client.Providers()
    
    static var webServices: WebServices = PIAWebServices()

    #if os(iOS) || os(tvOS)
    public static var store: InAppProvider = AppStoreProvider()
    #endif

    // MARK: Initialization

    /**
     Initializes the client. Strategies may only be customized before invoking
     this method. The step is mandatory for proper behavior.

     You probably want to do this as soon as the consumer application starts.
     */
    public static func bootstrap() {

        // preload servers from optionally bundled JSON
        if let data = configuration.bundledServersJSON {
            providers.serverProvider.loadLocalJSON(fromJSON: data)
        }

        // daemons (observe passive notifications regardless)
        ConnectivityDaemon.shared.start()
        if configuration.enablesConnectivityUpdates {
            ConnectivityDaemon.shared.enableUpdates()
        }
        ServersDaemon.shared.start()
        if configuration.enablesServerUpdates {
            ServersDaemon.shared.enableUpdates()
        }
        VPNDaemon.shared.start()
        VPNDaemon.shared.enableUpdates()

        // migrate from old token
        providers.accountProvider.migrateOldTokenIfNeeded { (error) in
            // If there was an error. It will force the user logout.
            guard let error = error as? ClientError else {
                return
            }
            log.debug("Client bootstrap migrateOldTokenIfNeeded error: \(error)")
            if (error == .unauthorized) {
                providers.accountProvider.logout(nil)
            }
        }
    }
    
    public static func resetServers(completionBlock: @escaping (Error?) -> Void) {
        ServersPinger.shared.reset()
        ServersDaemon.shared.reset()
        ServersDaemon.shared.forceUpdates(completionBlock: completionBlock)
    }
    
    public static func resetWebServices() {
        Client.webServices = PIAWebServices()
    }
    
    /**
     Refresh the list of plan products
     */
    public static func refreshProducts() {
        #if os(iOS)
        providers.accountProvider.listPlanProducts(nil)
        #endif
    }
    
    /**
    Observe Purchase transactions
    */
    public static func observeTransactions() {
        #if os(iOS)
        store.startObservingTransactions()
        #endif
    }

    /**
     Disposes the client resources and observers.
     
     Do this when the consumer application is about to terminate.
     */
    public static func dispose() {
        #if os(iOS)
        store.stopObservingTransactions()
        #endif
    }
    
    /**
     Refresh the ping number to the given servers
     */
    public static func ping(servers: [Server]) {
        ServersPinger.shared.ping(withDestinations: servers)
    }
}
