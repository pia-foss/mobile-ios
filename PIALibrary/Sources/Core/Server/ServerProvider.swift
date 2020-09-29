//
//  ServerProvider.swift
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

/// Business interface related to VPN servers.
public protocol ServerProvider: class {

    /// The `ServersBundle.Configuration` associated with this provider.
    ///
    /// - Seealso: `ServersBundle.Configuration`
    var currentServersConfiguration: ServersBundle.Configuration { get }

    /// The list of provided `Server`s.
    var currentServers: [Server] { get }
    
    /// The list of last connected `Server`s.
    var historicalServers: [Server] { get }

    /// The suggested best server to connect to.
    var bestServer: Server? { get }

    /// The target server for a VPN connection.
    ///
    /// - Seealso: `VPNProvider`
    var targetServer: Server { get }

    var regionStaticData: RegionData! { get }
    
    /**
     Loads this provider with a local JSON, as seen on the /servers web client API.

     - Postcondition:
        - Sets `currentServers` and `currentServersConfiguration`.
        - Posts `Notification.Name.PIAServerDidUpdateCurrentServers`.
     - Parameter jsonData: The JSON data to load.
     */
    func loadLocalJSON(fromJSON jsonData: Data)

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
     Downloads the region static data (geolocation, localized server name, etc).
     - Parameter callback: Returns the callback when the operation is completed.

     */
    func downloadRegionStaticData(_ callback: SuccessLibraryCallback?)

    /**
     Looks for a server via its `Server.identifier`.

     - Parameter identifier: The identifier to look for (e.g. "germany" for Germany).
     - Returns: The found `Server` object or `nil`.
     */
    func find(withIdentifier identifier: String) -> Server?
    
    /**
     Reset the currentServers object
     */
    func resetCurrentServers()
}
