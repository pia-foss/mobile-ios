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

@available(tvOS 17.0, *)
open class DefaultServerProvider: ServerProvider, ConfigurationAccess, DatabaseAccess, PreferencesAccess, WebServicesAccess, WebServicesConsumer {
    
    private let customWebServices: WebServices?
    private let renewDedicatedIP: RenewDedicatedIPUseCaseType
    private let getDedicatedIPs: GetDedicatedIPsUseCaseType
    private let dedicatedIPServerMapper: DedicatedIPServerMapperType
    
    init(webServices: WebServices? = nil, renewDedicatedIP: RenewDedicatedIPUseCaseType, getDedicatedIPs: GetDedicatedIPsUseCaseType, dedicatedIPServerMapper: DedicatedIPServerMapperType) {
        if let webServices = webServices {
            customWebServices = webServices
        } else {
            customWebServices = nil
        }
        
        self.renewDedicatedIP = renewDedicatedIP
        self.getDedicatedIPs = getDedicatedIPs
        self.dedicatedIPServerMapper = dedicatedIPServerMapper
    }

    // MARK: ServerProvider
    
    public var currentServersConfiguration: ServersBundle.Configuration {
        return accessedDatabase.transient.serversConfiguration
    }
    
    public var historicalServers: [Server] {
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
    
    public var currentServers: [Server] {
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
    
    public var bestServer: Server? {
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
    
    public var targetServer: Server {
        guard let server = accessedPreferences.preferredServer ?? bestServer ?? accessedDatabase.plain.lastConnectedRegion else {
            guard let fallbackServer = currentServers.first else {
                fatalError("No servers available")
            }
            return fallbackServer
        }
        return server
    }
    
    public var dipTokens: [String]? {
        return accessedDatabase.secure.dipTokens()
    }
    
    public func loadLocalJSON(fromJSON jsonData: Data) {
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

    public func load(fromJSON jsonData: Data) {
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
    
    private func handleDownloadDIPsResponse(_ response: Result<[Server], ClientError>, bundle: ServersBundle, callback: (([Server]?, Error?) -> Void)?) {
        switch response {
            case .success(let servers):
                var allServers = bundle.servers
                
                for server in servers where !bundle.servers.contains(where: {$0.dipToken == server.dipToken}) {
                    allServers.append(server)
                }
            
                
                currentServers = allServers
                DispatchQueue.main.async { [self] in
                    Macros.postNotification(.PIAThemeDidChange)
                    callback?(currentServers, nil)
                }
                
            case .failure(let clientError):
                DispatchQueue.main.async { [self] in
                    callback?(currentServers, clientError)
                }
        }
    }
    
    public func download(_ callback: (([Server]?, Error?) -> Void)?) {
        webServices.downloadServers { (bundle, error) in
            guard let bundle = bundle else {
                callback?(nil, error)
                return
            }
            if let configuration = bundle.configuration {
                self.accessedDatabase.transient.serversConfiguration = configuration
            }
            
            if let tokens = self.accessedDatabase.secure.dipTokens(), !tokens.isEmpty {
                self.getDedicatedIPs(dipTokens: tokens) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let dedicatedIPServers):
                        let mapperResult = dedicatedIPServerMapper.map(dedicatedIps: dedicatedIPServers)
                        handleDownloadDIPsResponse(mapperResult, bundle: bundle, callback: callback)
                        
                    case .failure(let error):
                        let clientError = ClientErrorMapper.map(networkRequestError: error)
                        if clientError == .unauthorized {
                            DispatchQueue.main.async {
                                Client.providers.accountProvider.logout(nil)
                                Macros.postNotification(.PIAUnauthorized)
                            }
                        } else {
                            DispatchQueue.main.async { [self] in
                                callback?(self.currentServers, clientError)
                            }
                        }
                    }
                }
                
                /*
                
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
                }*/
            } else {
                self.currentServers = bundle.servers
                callback?(self.currentServers, error)
            }
        }
    }
    
    public func activateDIPToken(_ token: String, _ callback: LibraryCallback<Server?>?) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        
        getDedicatedIPs(dipTokens: [token]) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let servers):
                    DispatchQueue.main.async {
                        self.handleDIPServerResponse(self.dedicatedIPServerMapper.map(dedicatedIps: servers), callback)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        callback?(nil, ClientErrorMapper.map(networkRequestError: error))
                    }
            }
        }
    }
    
    private func handleDIPServerResponse(_ response: Result<[Server], ClientError>, _ callback: LibraryCallback<Server>?) {
        guard case .success(let servers) = response else {
            guard case .failure(let error) = response else {
                callback?(nil, ClientError.unexpectedReply)
                return
            }

            callback?(nil, error)
            return
        }
        
        guard let first = servers.first, let status = first.dipStatus else {
            callback?(nil, ClientError.unexpectedReply)
            return
        }
            
        if !self.currentServers.contains(where: {$0.dipToken == first.dipToken}) && status == .active {
            self.currentServers.append(contentsOf: servers)
        }
            
        callback?(first, nil)
    }

    public func activateDIPTokens(_ tokens: [String], _ callback: LibraryCallback<[Server]>?) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        
        getDedicatedIPs(dipTokens: tokens) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let servers):
                    DispatchQueue.main.async {
                        self.handleDIPServersResponse(self.dedicatedIPServerMapper.map(dedicatedIps: servers), callback)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        callback?([], ClientErrorMapper.map(networkRequestError: error))
                    }
            }
        }
    }
    
    private func handleDIPServersResponse(_ response: Result<[Server], ClientError>, _ callback: LibraryCallback<[Server]>?) {
        guard case .success(let servers) = response else {
            guard case .failure(let error) = response else {
                callback?(nil, ClientError.unexpectedReply)
                return
            }

            callback?(nil, error)
            return
        }
            
        for server in servers where !self.currentServers.contains(where: {$0.dipToken == server.dipToken}) {
            self.currentServers.append(server)
        }
            
        callback?(servers, nil)
    }
    
    public func removeDIPToken(_ dipToken: String) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        accessedDatabase.secure.remove(dipToken)
        //self.currentServers = self.currentServers.filter({$0.dipToken != dipToken})
    }
    
    public func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?) {
        guard Client.providers.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        
        renewDedicatedIP(dipToken: dipToken, completion: { _ in })
    }
    
    public func find(withIdentifier identifier: String) -> Server? {
        return currentServers.first { $0.identifier == identifier }
    }
    
    public func resetCurrentServers() {
        currentServers = []
    }
    // MARK: WebServicesConsumer

    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }
}

@available(tvOS 17.0, *)
extension Server: DatabaseAccess {

    /// Returns last ping response in milliseconds. Requires `Library` subspec.
    public var pingTime: Int? {
        return accessedDatabase.plain.ping(forServerIdentifier: identifier)
    }
}
