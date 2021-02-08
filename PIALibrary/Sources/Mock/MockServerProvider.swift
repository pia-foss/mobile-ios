//
//  MockServerProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/17/17.
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

/// Simulates server-related operations
public class MockServerProvider: ServerProvider, DatabaseAccess, WebServicesConsumer {

    /// Fakes a `Server` list.
    public var mockServers: [Server]

    let webServices: WebServices
    
    private let delegate: ServerProvider
    
    /// :nodoc:
    public init() {
        mockServers = [
            Server(
                serial: "8a55f03812851897f6e43b2ae22b1234",
                name: "France",
                country: "fr",
                hostname: "france.example.com",
                pingAddress: nil,
                responseTime: 0,
                regionIdentifier: ""
            ), Server(
                serial: "8a55f03812851897f6e43b2ae22b1234",
                name: "Germany",
                country: "de",
                hostname: "germany.example.com",
                pingAddress: nil,
                responseTime: 0,
                regionIdentifier: ""
            ), Server(
                serial: "8a55f03812851897f6e43b2ae22b1234",
                name: "Italy",
                country: "it",
                hostname: "italy.example.com",
                pingAddress: nil,
                responseTime: 0,
                regionIdentifier: ""
            ), Server(
                serial: "8a55f03812851897f6e43b2ae22b1234",
                name: "US East",
                country: "us",
                hostname: "us-east.example.com",
                pingAddress: nil,
                responseTime: 0,
                regionIdentifier: ""
            ), Server(
                serial: "8a55f03812851897f6e43b2ae22b1234",
                name: "US East Offline",
                country: "us",
                hostname: "us-east.example.com",
                pingAddress: nil,
                responseTime: 0,
                geo: true,
                offline: true,
                regionIdentifier: ""
            )
        ]

        let webServices = MockWebServices()
        delegate = DefaultServerProvider(webServices: webServices)
        self.webServices = webServices
        
        webServices.serversBundle = {
            return ServersBundle(servers: self.mockServers, configuration: nil)
        }
    }
    
    // MARK: ServerProvider
    
    /// :nodoc:
    public var currentServersConfiguration: ServersBundle.Configuration {
        return accessedDatabase.transient.serversConfiguration
    }
    
    /// :nodoc:
    public var historicalServers: [Server] {
        //        return delegate.currentServers
        return mockServers
    }

    /// :nodoc:
    public var currentServers: [Server] {
//        return delegate.currentServers
        return mockServers
    }
    
    /// :nodoc:
    public var bestServer: Server? {
//        return delegate.bestServer
        return mockServers.first
    }
    
    /// :nodoc:
    public var targetServer: Server {
//        return delegate.targetServer
        return mockServers.last!
    }
    
    public var dipTokens: [String]? {
        return []
    }
    
    /// :nodoc:
    public func load(fromJSON jsonData: Data) {
        return delegate.load(fromJSON: jsonData)
    }
    
    /// :nodoc:
    public func loadLocalJSON(fromJSON jsonData: Data) {
        return delegate.loadLocalJSON(fromJSON: jsonData)
    }
    
    /// :nodoc:
    public func download(_ callback: (([Server]?, Error?) -> Void)?) {
        delegate.download(callback)
    }
    
    /// :nodoc:
    public func find(withIdentifier identifier: String) -> Server? {
        return delegate.find(withIdentifier: identifier)
    }
        
    public func resetCurrentServers() {
    }
    
    public func removeDIPToken(_ dipToken: String) {
        delegate.removeDIPToken(dipToken)
    }
    
    public func activateDIPToken(_ token: String, _ callback: LibraryCallback<Server?>?) {
        delegate.activateDIPToken(token, callback)
    }
    
    public func activateDIPTokens(_ tokens: [String], _ callback: LibraryCallback<[Server]>?) {
        delegate.activateDIPTokens(tokens, callback)
    }
    
    public func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?) {
        delegate.handleDIPTokenExpiration(dipToken: dipToken, callback)
    }
}
