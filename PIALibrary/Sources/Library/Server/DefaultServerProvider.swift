//
//  DefaultServerProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/11/17.
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
    
    var historicalServers: [Server] {
        get {
            return accessedDatabase.plain.historicalServers
        }
        set {
            accessedDatabase.plain.cachedServers = newValue
        }
    }
    
    var currentServers: [Server] {
        get {
            return accessedDatabase.plain.cachedServers
        }
        set {
            var servers = newValue
            servers.insert(contentsOf: accessedConfiguration.customServers, at: 0)
            accessedDatabase.plain.cachedServers = servers

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
        let servers = currentServers.filter { $0.serverNetwork == Client.configuration.currentServerNetwork() }
        for server in servers {
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
            
            // GEO servers can't autoconnect
            guard !server.geo else {
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
            guard let fallbackServer = currentServers.first else {
                fatalError("No servers available")
            }
            return fallbackServer
        }
        return server
    }
    
    func loadLocalJSON(fromJSON jsonData: Data) {
        guard let bundle = GlossServersBundle(jsonData: jsonData, forServerNetwork: .legacy) else {
            return
        }
        if let configuration = bundle.parsed.configuration {
            accessedDatabase.transient.serversConfiguration = configuration
        }
        if currentServers.isEmpty {
            currentServers = bundle.parsed.servers
        }
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
