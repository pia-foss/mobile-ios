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

    // MARK: Server
    
    var cachedServers: [Server] { get set }
    
    var preferredServer: Server? { get set }
    
    func ping(forServerIdentifier serverIdentifier: String) -> Int?
    
    func setPing(_ ping: Int, forServerIdentifier serverIdentifier: String)
    
    func serializePings()
    
    func clearPings()
    
    // MARK: VPN
    
    var vpnType: String? { get set }
    
    var vpnDisconnectsOnSleep: Bool { get set }
    
    var vpnCustomConfigurationMaps: [String: [String: Any]]? { get set }

    // MARK: Preferences
    
    var isPersistentConnection: Bool? { get set }
    
    var shouldConnectWithUnsecuredNetworks: Bool? { get set }

    var shouldConnectForAllNetworks: Bool? { get set }

    var mace: Bool? { get set }
    
    // MARK: Lifecycle
    
    func reset()
    
    func clear()
    
    // MARK: Netwokrs
    var cachedNetworks: [String] { get set }
    
    var trustedNetworks: [String] { get set }
}
