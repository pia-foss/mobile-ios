//
//  PlainStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol PlainStore: class {

    // MARK: Account
        
    var accountInfo: AccountInfo? { get set }
    
    var lastSignupEmail: String? { get set }
    
    // MARK: IP

    var publicIP: String? { get set }

    // MARK: Server
    var historicalServers: [Server] { get set }

    var cachedServers: [Server] { get set }
    
    var preferredServer: Server? { get set }
    
    func ping(forServerIdentifier serverIdentifier: String) -> Int?
    
    func setPing(_ ping: Int, forServerIdentifier serverIdentifier: String)
    
    func serializePings()
    
    func clearPings()
    
    // MARK: Tiles
    var visibleTiles: [AvailableTiles] {get set}
    
    var orderedTiles: [AvailableTiles] {get set}

    // MARK: VPN
    
    var vpnType: String? { get set }
    
    var vpnDisconnectsOnSleep: Bool { get set }
    
    var vpnCustomConfigurationMaps: [String: [String: Any]]? { get set }

    // MARK: Preferences
    
    var isPersistentConnection: Bool? { get set }

    var shouldConnectForAllNetworks: Bool? { get set }

    var useWiFiProtection: Bool? { get set }

    var trustCellularData: Bool? { get set }

    var authMigrationSuccess: Bool? { get set }

    var mace: Bool? { get set }
    
    // MARK: Lifecycle
    
    func reset()
    
    func clear()
    
    // MARK: Networks
    var cachedNetworks: [String] { get set }
    
    var trustedNetworks: [String] { get set }
    
    var nmtRulesEnabled: Bool? { get set }

    //MARK: IKEv2
    var ikeV2IntegrityAlgorithm: String { get set }
    
    var ikeV2EncryptionAlgorithm: String { get set }

}
