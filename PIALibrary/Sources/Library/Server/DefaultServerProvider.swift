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
            if let dipTokens = dipTokens {
                return accessedDatabase.plain.historicalServers.filter({$0.dipToken == nil || dipTokens.contains($0.dipToken ?? "")})
            }
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
        guard let server = accessedPreferences.preferredServer ?? bestServer ?? accessedDatabase.plain.lastConnectedRegion else {
            guard let fallbackServer = currentServers.first else {
                fatalError("No servers available")
            }
            return fallbackServer
        }
        return server
    }
    
    var dipTokens: [String]? {
        return accessedDatabase.secure.dipTokens()
    }
    
    func loadLocalJSON(fromJSON jsonData: Data) {
        guard let bundle = GlossServersBundle(jsonData: jsonData) else {
            return
        }
        if let configuration = bundle.parsed.configuration {
            accessedDatabase.transient.serversConfiguration = configuration
        }
        if currentServers.isEmpty {
            currentServers = bundle.parsed.servers
            ServersPinger.shared.ping(withDestinations: currentServers)
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
            
            if let tokens = self.accessedDatabase.secure.dipTokens(), !tokens.isEmpty {
                self.webServices.activateDIPToken(tokens: tokens) { (servers, error) in
                    
                    if error != nil, error as! ClientError == ClientError.unauthorized {
                        Client.providers.accountProvider.logout(nil)
                        Macros.postNotification(.PIAUnauthorized)
                        return
                    }

                    var allServers = bundle.servers
                    
                    if let servers = servers {
                        for server in servers {
                            if !bundle.servers.contains(where: {$0.dipToken == server.dipToken}) {
                                allServers.append(server)
                            }
                        }
                    }
                    
                    self.currentServers = allServers
                    Macros.postNotification(.PIAThemeDidChange)
                    callback?(self.currentServers, error)
                }
            } else {
                self.currentServers = bundle.servers
                callback?(self.currentServers, error)
            }
            
        }
    }
    
    func activateDIPToken(_ token: String, _ callback: LibraryCallback<Server?>?) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        webServices.activateDIPToken(tokens: [token]) { (servers, error) in
            if let servers = servers,
               let first = servers.first,
               let status = first.dipStatus {
                if !self.currentServers.contains(where: {$0.dipToken == first.dipToken}) && status == .active {
                    self.currentServers.append(contentsOf: servers)
                }
                callback?(first, error)
            } else {
                callback?(nil, error)
            }
        }
    }

    func activateDIPTokens(_ tokens: [String], _ callback: LibraryCallback<[Server]>?) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        webServices.activateDIPToken(tokens: tokens) { (servers, error) in
            if let servers = servers {
                for server in servers {
                    if !self.currentServers.contains(where: {$0.dipToken == server.dipToken}) {
                        self.currentServers.append(server)
                    }
                }
                callback?(servers, error)
            } else {
                callback?([], error)
            }
        }
    }
    
    func removeDIPToken(_ dipToken: String) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        accessedDatabase.secure.remove(dipToken)
        //self.currentServers = self.currentServers.filter({$0.dipToken != dipToken})
    }
    
    func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        webServices.handleDIPTokenExpiration(dipToken: dipToken, nil)
    }
    
    func find(withIdentifier identifier: String) -> Server? {
        return currentServers.first { $0.identifier == identifier }
    }
    
    func resetCurrentServers() {
        currentServers = []
    }
    // MARK: WebServicesConsumer

    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }
}

extension Server: DatabaseAccess {

    /// Returns last ping response in milliseconds. Requires `Library` subspec.
    public var pingTime: Int? {
        return accessedDatabase.plain.ping(forServerIdentifier: identifier)
    }
}
