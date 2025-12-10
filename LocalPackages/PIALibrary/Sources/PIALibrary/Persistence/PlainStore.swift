//
//  PlainStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
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

protocol PlainStore: class {

    // MARK: Account
        
    var accountInfo: AccountInfo? { get set }
    
    var lastSignupEmail: String? { get set }

    var tokenMigrated: Bool { get set }
    
    // MARK: IP

    var publicIP: String? { get set }

    // MARK: Server
    
    var historicalServers: [Server] { get set }

    var cachedServers: [Server] { get set }
    
    var preferredServer: Server? { get set }

    var lastConnectedRegion: Server? { get set }

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

    var lastKnownVpnStatus: VPNStatus { get set }
    
    var lastVPNConnectionAttempt: Double { get set }

    var lastVPNConnectionSuccess: Double? { get set }
    
    var timeToConnectVPN: Double { get set }

    var wireguardMigrationPerformed: Bool { get set }
    
    var leakProtection: Bool { get set }
    
    var allowLocalDeviceAccess: Bool { get set }
    
    var currentRFC1918VulnerableWifi: String? { get set }

    // MARK: Service Quality
    
    var versionWhenServiceQualityOpted: String? { get set }
    
    var lastKnownException: String? { get set }
    
    // MARK: Preferences
    
    var isPersistentConnection: Bool? { get set }

    var nmtMigrationSuccess: Bool? { get set }

    var mace: Bool? { get set }
    
    // MARK: Lifecycle
    
    func reset()
    
    func clear()
    
    // MARK: Networks
    var cachedNetworks: [String] { get set }
    
    var nmtRulesEnabled: Bool? { get set }
    
    var nmtGenericRules: [String: Int] {get set}

    var nmtTrustedNetworkRules: [String: Int] {get set}

    var nmtTemporaryOpenNetworks: [String] {get set}

    //MARK: IKEv2
    var ikeV2IntegrityAlgorithm: String { get set }
    
    var ikeV2EncryptionAlgorithm: String { get set }

    var ikeV2PacketSize: Int { get set }

    //MARK: Sign in with Apple
    var signInWithAppleFakeEmail: String? { get set }

    //MARK: Deprecated
    var useWiFiProtection: Bool? { get set }

    var trustCellularData: Bool? { get set }

    var trustedNetworks: [String] { get set }
    
    var shareServiceQualityData: Bool? { get set }

}
