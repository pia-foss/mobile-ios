//
//  MockServerProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/17/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
                name: "France",
                country: "fr",
                hostname: "france.example.com",
                bestOpenVPNAddressForTCP: nil,
                bestOpenVPNAddressForUDP: nil,
                pingAddress: nil
            ), Server(
                name: "Germany",
                country: "de",
                hostname: "germany.example.com",
                bestOpenVPNAddressForTCP: nil,
                bestOpenVPNAddressForUDP: nil,
                pingAddress: nil
            ), Server(
                name: "Italy",
                country: "it",
                hostname: "italy.example.com",
                bestOpenVPNAddressForTCP: nil,
                bestOpenVPNAddressForUDP: nil,
                pingAddress: nil
            ), Server(
                name: "US East",
                country: "us",
                hostname: "us-east.example.com",
                bestOpenVPNAddressForTCP: nil,
                bestOpenVPNAddressForUDP: nil,
                pingAddress: nil
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
    
    /// :nodoc:
    public func load(fromJSON jsonData: Data) {
        return delegate.load(fromJSON: jsonData)
    }
    
    /// :nodoc:
    public func download(_ callback: (([Server]?, Error?) -> Void)?) {
        delegate.download(callback)
    }
    
    /// :nodoc:
    public func find(withIdentifier identifier: String) -> Server? {
        return delegate.find(withIdentifier: identifier)
    }
    
    /// :nodoc:
    public func flagURL(for server: Server) -> URL {
        return delegate.flagURL(for: server)
    }
}
