//
//  ServerProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/11/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Business interface related to VPN servers.
public protocol ServerProvider: class {

    /// The `ServersBundle.Configuration` associated with this provider.
    ///
    /// - Seealso: `ServersBundle.Configuration`
    var currentServersConfiguration: ServersBundle.Configuration { get }

    /// The list of provided `Server`s.
    var currentServers: [Server] { get }

    /// The suggested best server to connect to.
    var bestServer: Server? { get }

    /// The target server for a VPN connection.
    ///
    /// - Seealso: `VPNProvider`
    var targetServer: Server { get }
    
    /**
     Loads this provider with a JSON, as seen on the /servers web client API.

     - Postcondition:
        - Sets `currentServers` and `currentServersConfiguration`.
        - Posts `Notification.Name.PIAServerDidUpdateCurrentServers`.
     - Parameter jsonData: The JSON data to load.
     */
    func load(fromJSON jsonData: Data)

    /**
     Downloads or refreshes the current servers and configuration.
 
     - Postcondition:
        - Updates `currentServers` and `currentServersConfiguration`.
     - Parameter callback: Returns the new list of `Server` objects.
     */
    func download(_ callback: LibraryCallback<[Server]>?)

    /**
     Looks for a server via its `Server.identifier`.

     - Parameter identifier: The identifier to look for (e.g. "germany" for Germany).
     - Returns: The found `Server` object or `nil`.
     */
    func find(withIdentifier identifier: String) -> Server?

    /**
     Returns the URL where to find a flag asset associated with a server.

     - Parameter server: The `Server` to fetch the flag for.
     - Returns: The `URL` of the flag asset. The asset is not guaranteed to be available.
     */
    func flagURL(for server: Server) -> URL
}
