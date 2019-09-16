//
//  Client.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import SwiftyBeaver

private let log = SwiftyBeaver.self

/// The entry point for client initialization and usage.
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

    #if os(iOS)
    static var store: InAppProvider = AppStoreProvider()
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
            providers.serverProvider.load(fromJSON: data)
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
