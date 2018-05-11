//
//  DefaultServerProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/11/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import __PIALibraryNative

class DefaultServerProvider: ServerProvider, ConfigurationAccess, DatabaseAccess, PreferencesAccess, WebServicesAccess, WebServicesConsumer {
    private let customWebServices: WebServices?
    
    init(webServices: WebServices? = nil) {
        if let webServices = webServices {
            customWebServices = webServices
        } else {
            customWebServices = nil
        }
    }

    // MARK: ServerProvider
    
    var currentServersConfiguration: ServersBundle.Configuration {
        return accessedDatabase.transient.serversConfiguration
    }
    
    var currentServers: [Server] {
        get {
            return accessedDatabase.plain.cachedServers
        }
        set {
            accessedDatabase.plain.cachedServers = newValue
            if accessedConfiguration.isDevelopment {
                let chipotle = Server(
                    name: "chipotle251",
                    country: "US",
                    hostname: "chipotle251.privateinternetaccess.com",
                    bestOpenVPNAddressForTCP: nil,
                    bestOpenVPNAddressForUDP: Server.Address(hostname: "108.61.57.211", port: 8080),
                    pingAddress: nil
                )
                accessedDatabase.plain.cachedServers.insert(chipotle, at: 0)
            }

            Macros.postNotification(.PIAServerDidUpdateCurrentServers, [
                .servers: newValue
            ])
        }
    }
    
    var bestServer: Server? {
        var bestIdentifier: String?
        var bestResponseTime: Int = .max
        
//        for (identifier, history) in accessedDatabase.plain.pingsServerIdentifier {
//            guard let avg = history.avg() else {
//                continue
//            }
//            guard (avg < bestResponseTime) else {
//                continue
//            }
        for server in currentServers {
            guard let responseTime = accessedDatabase.plain.ping(forServerIdentifier: server.identifier) else {
                continue
            }
            guard (responseTime < bestResponseTime) else {
                continue
            }
//            if let automaticIdentifiers = accessedDatabase.transient.serversConfiguration.automaticIdentifiers {
//                guard automaticIdentifiers.contains(server.identifier) else {
//                    continue
//                }
//            }
            guard server.isAutomatic else {
                continue
            }
            bestIdentifier = server.identifier
            bestResponseTime = responseTime
        }
        guard let _ = bestIdentifier else {
            return nil
        }
        return find(withIdentifier: bestIdentifier!)
    }
    
    var targetServer: Server {
        guard let server = accessedPreferences.preferredServer ?? bestServer else {
            guard let fallbackServer = find(withIdentifier: accessedConfiguration.fallbackServerIdentifier) else {
                fatalError("No servers available")
            }
            return fallbackServer
        }
        return server
    }
    
    func load(fromJSON jsonData: Data) {
        guard let bundle = GlossServersBundle(jsonData: jsonData) else {
            return
        }
        if let configuration = bundle.parsed.configuration {
            accessedDatabase.transient.serversConfiguration = configuration
        }
        if currentServers.isEmpty {
            currentServers = bundle.parsed.servers
        }
    }
    
    func download(_ callback: (([Server]?, Error?) -> Void)?) {
        webServices.downloadServers { (bundle, error) in
            guard let bundle = bundle else {
                callback?(nil, error)
                return
            }
            if let configuration = bundle.configuration {
                self.accessedDatabase.transient.serversConfiguration = configuration
            }
            self.currentServers = bundle.servers
            callback?(bundle.servers, error)
        }
    }
    
    func find(withIdentifier identifier: String) -> Server? {
        return currentServers.first { $0.identifier == identifier }
    }
    
    func flagURL(for server: Server) -> URL {
        return webServices.flagURL(for: server.country.lowercased())
    }

    // MARK: WebServicesConsumer

    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }
}

extension Server: ProvidersAccess {

    /// Shortcut for `ServerProvider.flagURL(for:)` as per `Client.Providers.serverProvider`. Requires `Library` subspec.
    public var flagURL: URL {
        return accessedProviders.serverProvider.flagURL(for: self)
    }
}

extension Server: DatabaseAccess {

    /// Returns last ping response in milliseconds. Requires `Library` subspec.
    public var pingTime: Int? {
        return accessedDatabase.plain.ping(forServerIdentifier: identifier)
    }
}
