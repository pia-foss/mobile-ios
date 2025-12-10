//
//  UserDefaultsStore.swift
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
import Gloss
import SwiftyBeaver

private let log = SwiftyBeaver.self

@available(tvOS 17.0, *)
class UserDefaultsStore: PlainStore, ConfigurationAccess {
    private struct Entries {
        static let username = "LoggedUsername" // legacy
        
        static let accountInfo = "LoggedAccountInfo" // legacy

        static let lastSignupEmail = "LastSignupEmail"

        static let tokenMigrated = "TokenMigrated"
        
        static let publicIP = "PublicIP"

        static let historicalServers = "HistoricalServers"

        static let cachedServers = "CachedServers"

        static let serversConfiguration = "ServersConfiguration"
        
        static let preferredServer = "CurrentRegion" // legacy

        static let lastConnectedRegion = "LastConnectedRegion" 

        static let preferredServerDIPToken = "CurrentRegionDIPToken"
        
        static let pingByServerIdentifier = "PingByServerIdentifier"
        
        static let vpnType = "VPNType"
        
        static let vpnDisconnectsOnSleep = "VPNDisconnectsOnSleep"
        
        static let vpnCustomConfigurationMaps = "VPNCustomConfigurationMaps"

        static let lastKnownVpnStatus = "LastKnownVPNStatus"

        static let persistentConnection = "PersistentConnection" // legacy

        static let mace = "MACE" // legacy
        
        static let visibleTiles = "VisibleTiles"

        static let orderedTiles = "OrderedTiles"

        static let useWiFiProtection = "UseWiFiProtection"

        static let trustCellularData = "TrustCellularData"

        static let nmtMigrationSuccess = "NMTMigrationSuccess"

        static let trustedNetworks = "TrustedNetworks"
        
        static let serverNetwork = "ServerNetwork"

        static let ikeV2IntegrityAlgorithm = "IKEV2IntegrityAlgorithm"
        
        static let ikeV2EncryptionAlgorithm = "IKEV2EncryptionAlgorithm"

        static let ikeV2PacketSize = "IKEV2PacketSize"

        static let signInWithAppleFakeEmail = "SignInWithAppleFakeEmail"

        static let nmtRulesEnabled = "NMTRulesEnabled"

        static let cachedNetworks = "CachedNetworks"

        static let nmtTrustedNetworkRules = "NMTTrustedNetworkRules"

        static let nmtTemporaryOpenNetworks = "NMTTemporaryOpenNetworks"

        static let nmtGenericRules = "NMTGenericRules"

        static let shareServiceQualityData = "ShareServiceQualityData"
        
        static let lastKnownException = "LastKnownException"

        static let versionWhenServiceQualityOpted = "versionWhenServiceQualityOpted"
        
        static let lastVPNConnectionAttempt = "lastVPNConnectionAttempt"

        static let lastVPNConnectionSuccess = "lastVPNConnectionSuccess"
        
        static let timeToConnectVPN = "timeToConnectVPN"

        static let wireguardMigrationPerformed = "WireguardMigrationPerformed"
        
        static let leakProtection = "LeakProtection"
        
        static let allowLocalDeviceAccess = "AllowLocalDeviceAccess"
        
        static let currentRFC1918VulnerableWifi = "CurrentRFC1918VulnerableWifi"
    }
    
    private let backend: UserDefaults
    
    private let group: String?
    
    private var historicalServersCopy: [Server]?

    private var cachedServersCopy: [Server]?
    
    private var visibleTilesCopy: [AvailableTiles]?

    private var orderedTilesCopy: [AvailableTiles]?

    private var serversConfigurationCopy: ServersBundle.Configuration?
    
    private var pingByServerIdentifier: [String: Int] = [:]
    
    init() {
        backend = UserDefaults.standard
        group = Bundle.main.bundleIdentifier
        loadComplexMaps()
    }

    init(group: String) {
        guard let backend = UserDefaults(suiteName: group) else {
            fatalError("Unable to create UserDefaults in app group '\(group)')")
        }
        self.backend = backend
        self.group = group
        loadComplexMaps()
    }
    
    private func loadComplexMaps() {
        pingByServerIdentifier = backend.dictionary(forKey: Entries.pingByServerIdentifier) as? [String: Int] ?? [:]
    }
    
    deinit {
        backend.synchronize()
    }
    
    // MARK: PlainStore
    
    // MARK: Account

    var publicUsername: String? {
        get {
            return backend.string(forKey: Entries.username)
        }
        set {
            if let username = newValue {
                backend.set(username, forKey: Entries.username)
            } else {
                backend.removeObject(forKey: Entries.username)
            }
        }
    }

    var accountInfo: AccountInfo? {
        get {
            guard let info = backend.dictionary(forKey: Entries.accountInfo) else {
                return nil
            }
            return GlossAccountInfo(json: info)?.parsed
        }
        set {
            if let info = newValue {
                backend.set(info.toJSON(), forKey: Entries.accountInfo)
            } else {
                backend.removeObject(forKey: Entries.accountInfo)
            }
        }
    }
    
    var lastSignupEmail: String? {
        get {
            return backend.string(forKey: Entries.lastSignupEmail)
        }
        set {
            if let email = newValue {
                backend.set(email, forKey: Entries.lastSignupEmail)
            } else {
                backend.removeObject(forKey: Entries.lastSignupEmail)
            }
        }
    }

    var tokenMigrated: Bool {
        get {
            return backend.bool(forKey: Entries.tokenMigrated)
        }
        set {
            backend.set(newValue, forKey: Entries.tokenMigrated)
        }
    }
    
    var publicIP: String? {
        get {
            return backend.string(forKey: Entries.publicIP)
        }
        set {
            if let publicIP = newValue {
                backend.set(publicIP, forKey: Entries.publicIP)
            } else {
                backend.removeObject(forKey: Entries.publicIP)
            }
        }
    }
    
    var visibleTiles: [AvailableTiles] {
        get {
            if let copy = visibleTilesCopy {
                return copy
            }
            guard let intArray = backend.array(forKey: Entries.visibleTiles) as? [Int] else {
                return AvailableTiles.defaultTiles()
            }
            var tiles: [AvailableTiles] = []
            for value in intArray {
                if let tile = AvailableTiles(rawValue: value) {
                    tiles.append(tile)
                }
            }
            return tiles
        }
        set {
            var intArray: [Int] = []
            for value in newValue {
                intArray.append(value.rawValue)
            }
            backend.set(intArray, forKey: Entries.visibleTiles)
        }
    }
    
    var orderedTiles: [AvailableTiles] {
        get {
            if let copy = orderedTilesCopy {
                return copy
            }
            guard let intArray = backend.array(forKey: Entries.orderedTiles) as? [Int] else {
                return AvailableTiles.allTiles()
            }
            var tiles: [AvailableTiles] = []
            for value in intArray {
                if let tile = AvailableTiles(rawValue: value) {
                    tiles.append(tile)
                }
            }
            //Add new tiles when needed 
            if tiles.count < AvailableTiles.defaultOrderedTiles().count {
                for defaultTile in AvailableTiles.defaultOrderedTiles() {
                    if !tiles.contains(defaultTile) {
                        tiles.append(defaultTile)
                    }
                }
            }
            return tiles
        }
        set {
            var intArray: [Int] = []
            for value in newValue {
                intArray.append(value.rawValue)
            }
            backend.set(intArray, forKey: Entries.orderedTiles)
        }
    }

    
    // MARK: Server
    var historicalServers: [Server] {
        get {
            if let copy = historicalServersCopy {
                return copy
            }
            guard let jsonArray = backend.array(forKey: Entries.historicalServers) as? [JSON] else {
                return []
            }
            return Array<GlossServer>.from(jsonArray: jsonArray)?.map { $0.parsed } ?? []
        }
        set {
            var servers = newValue
            if servers.count > Client.configuration.maxQuickConnectServers {
                servers.removeFirst()
            }
            historicalServersCopy = servers
            backend.set(servers.toJSONArray() ?? [], forKey: Entries.historicalServers)
        }
    }

    var cachedServers: [Server] {
        get {
            if let copy = cachedServersCopy {
                return copy
            }
            guard let jsonArray = backend.array(forKey: Entries.cachedServers) as? [JSON] else {
                return []
            }
            return Array<GlossServer>.from(jsonArray: jsonArray)?.map { $0.parsed } ?? []
        }
        set {
            cachedServersCopy = newValue
            backend.set(newValue.toJSONArray() ?? [], forKey: Entries.cachedServers)
        }
    }
    
    var preferredServer: Server? {
        get {
            let identifier = backend.string(forKey: Entries.preferredServer)
            let dipToken = preferredServerDIPToken
            return cachedServers.first { $0.identifier == identifier && $0.dipToken == dipToken }
        }
        set {
            backend.set(newValue?.identifier, forKey: Entries.preferredServer)
            backend.set(newValue?.dipToken, forKey: Entries.preferredServerDIPToken)
            var lastServers = historicalServers
            if let server = newValue {
                
                let filtered = lastServers.filter({$0.name == server.name})
                if filtered.count != 0,
                    let indexOfServer = lastServers.firstIndex(of: server) {
                    lastServers.remove(at: indexOfServer)
                    lastServers.insert(server, at: lastServers.count)
                } else {
                    lastServers.append(server)
                }
                historicalServers = lastServers
            }
        }
    }
    
    var lastConnectedRegion: Server? {
        get {
            let identifier = backend.string(forKey: Entries.lastConnectedRegion)
            return cachedServers.first { $0.identifier == identifier }
        }
        set {
            backend.set(newValue?.identifier, forKey: Entries.lastConnectedRegion)
        }
    }
    
    var preferredServerDIPToken: String? {
        get {
            return backend.string(forKey: Entries.preferredServerDIPToken)
        }
        set {
            backend.set(preferredServerDIPToken, forKey: Entries.preferredServerDIPToken)
        }
    }

    func ping(forServerIdentifier serverIdentifier: String) -> Int? {
        return pingByServerIdentifier[serverIdentifier]
    }
    
    func setPing(_ ping: Int, forServerIdentifier serverIdentifier: String) {
        
        if let currentResponseTime = pingByServerIdentifier[serverIdentifier]{
            if currentResponseTime > ping {
                pingByServerIdentifier[serverIdentifier] = ping
            }
        } else {
            pingByServerIdentifier[serverIdentifier] = ping
        }

    }
    
    func serializePings() {
        backend.set(pingByServerIdentifier, forKey: Entries.pingByServerIdentifier)
    }
    
    func clearPings() {
        pingByServerIdentifier.removeAll()
    }
    
    // MARK: VPN
    
    var vpnType: String? {
        get {
            return backend.string(forKey: Entries.vpnType)
        }
        set {
            backend.set(newValue, forKey: Entries.vpnType)
        }
    }
    
    var vpnDisconnectsOnSleep: Bool {
        get {
            return backend.bool(forKey: Entries.vpnDisconnectsOnSleep)
        }
        set {
            backend.set(newValue, forKey: Entries.vpnDisconnectsOnSleep)
        }
    }
    
    var vpnCustomConfigurationMaps: [String: [String : Any]]? {
        get {
            return backend.dictionary(forKey: Entries.vpnCustomConfigurationMaps) as? [String: [String: Any]]
        }
        set {
            backend.set(newValue, forKey: Entries.vpnCustomConfigurationMaps)
        }
    }
    
    var lastKnownVpnStatus: VPNStatus {
        get {
            return VPNStatus(rawValue: backend.string(forKey: Entries.lastKnownVpnStatus) ?? "") ?? .unknown
        }
        set {
            backend.set(newValue.rawValue, forKey: Entries.lastKnownVpnStatus)
        }

    }
    
    var lastVPNConnectionAttempt: Double {
        get {
            return backend.double(forKey: Entries.lastVPNConnectionAttempt)
        }
        set {
            backend.set(newValue, forKey: Entries.lastVPNConnectionAttempt)
        }
    }

    var lastVPNConnectionSuccess: Double? {
        get {
            return backend.object(forKey: Entries.lastVPNConnectionSuccess) as? Double
        }
        set {
            backend.set(newValue, forKey: Entries.lastVPNConnectionSuccess)
        }
    }

    var timeToConnectVPN: Double {
        get {
            return backend.double(forKey: Entries.timeToConnectVPN)
        }
        set {
            backend.set(newValue, forKey: Entries.timeToConnectVPN)
        }
    }

    var wireguardMigrationPerformed: Bool {
        get {
            if backend.object(forKey: Entries.wireguardMigrationPerformed) == nil {
                backend.set(false, forKey: Entries.wireguardMigrationPerformed)
            }
            return backend.bool(forKey: Entries.wireguardMigrationPerformed)
        }
        set {
            backend.set(newValue, forKey: Entries.wireguardMigrationPerformed)
        }
    }
    
    var leakProtection: Bool {
        get {
            if backend.object(forKey: Entries.leakProtection) == nil {
                backend.set(true, forKey: Entries.leakProtection)
            }
            return backend.bool(forKey: Entries.leakProtection)
        }
        set {
            backend.set(newValue, forKey: Entries.leakProtection)
        }
    }
    
    var allowLocalDeviceAccess: Bool {
        get {
            if backend.object(forKey: Entries.allowLocalDeviceAccess) == nil {
                backend.set(true, forKey: Entries.allowLocalDeviceAccess)
            }
            return backend.bool(forKey: Entries.allowLocalDeviceAccess)
        }
        set {
            backend.set(newValue, forKey: Entries.allowLocalDeviceAccess)
        }
    }
    
    var currentRFC1918VulnerableWifi: String? {
        get {
            return backend.string(forKey: Entries.currentRFC1918VulnerableWifi)
        }
        set {
            backend.set(newValue, forKey: Entries.currentRFC1918VulnerableWifi)
        }
    }
    
    // MARK: Preferences

    var isPersistentConnection: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.persistentConnection) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.persistentConnection)
        }
    }
    
    var ikeV2IntegrityAlgorithm: String {
        get {
            guard let value = backend.object(forKey: Entries.ikeV2IntegrityAlgorithm) as? String else {
                return IKEv2IntegrityAlgorithm.defaultIntegrity.value()
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.ikeV2IntegrityAlgorithm)
        }
    }
    
    var ikeV2EncryptionAlgorithm: String {
        get {
            guard let value = backend.object(forKey: Entries.ikeV2EncryptionAlgorithm) as? String else {
                return IKEv2EncryptionAlgorithm.defaultAlgorithm.value()
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.ikeV2EncryptionAlgorithm)
        }
    }
    
    var ikeV2PacketSize: Int {
        get {
            guard let value = backend.object(forKey: Entries.ikeV2PacketSize) as? Int else {
                return 0
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.ikeV2PacketSize)
        }
    }

    var nmtMigrationSuccess: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.nmtMigrationSuccess) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.nmtMigrationSuccess)
        }
    }

    var mace: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.mace) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.mace)
        }
    }
    
    var signInWithAppleFakeEmail: String? {
        get {
            return backend.string(forKey: Entries.signInWithAppleFakeEmail)
        }
        set {
            backend.set(newValue, forKey: Entries.signInWithAppleFakeEmail)
        }
    }
    
    // MARK: Service Quality
    
    var shareServiceQualityData: Bool? {
        get {
            return backend.bool(forKey: Entries.shareServiceQualityData)
        }
        set {
            backend.set(newValue, forKey: Entries.shareServiceQualityData)
        }
    }
    
    var versionWhenServiceQualityOpted: String? {
        get {
            return backend.string(forKey: Entries.versionWhenServiceQualityOpted)
        }
        set {
            backend.set(newValue, forKey: Entries.versionWhenServiceQualityOpted)
        }
    }
    
    var lastKnownException: String? {
        get {
            return backend.string(forKey: Entries.lastKnownException) ?? ""
        }
        set {
            backend.set(newValue, forKey: Entries.lastKnownException)
        }
    }
    
    //MARK: Networks
    var cachedNetworks: [String] {
        get {
            guard let value = backend.object(forKey: Entries.cachedNetworks) as? [String] else {
                return []
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.cachedNetworks)
        }
    }

    var nmtTrustedNetworkRules: [String: Int] {
        get {
            guard let value = backend.dictionary(forKey: Entries.nmtTrustedNetworkRules) as? [String: Int] else {
                return [:]
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.nmtTrustedNetworkRules)
        }
    }
    
    var nmtTemporaryOpenNetworks: [String] {
        get {
            guard let value = backend.object(forKey: Entries.nmtTemporaryOpenNetworks) as? [String] else {
                return []
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.nmtTemporaryOpenNetworks)
        }
    }
    
    var nmtGenericRules: [String: Int] {
        get {
            guard let value = backend.dictionary(forKey: Entries.nmtGenericRules) as? [String: Int] else {
                return [:]
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.nmtGenericRules)
        }
    }

    var nmtRulesEnabled: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.nmtRulesEnabled) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.nmtRulesEnabled)
        }
    }

    ///Deprecated
    var trustCellularData: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.trustCellularData) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.trustCellularData)
        }
    }

    ///Deprecated
    var useWiFiProtection: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.useWiFiProtection) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.useWiFiProtection)
        }
    }
    
    ///Deprecated
    var trustedNetworks: [String] {
        get {
            guard let value = backend.object(forKey: Entries.trustedNetworks) as? [String] else {
                return []
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.trustedNetworks)
        }
    }

    // MARK: Lifecycle
    
    func reset() {
        backend.removeObject(forKey: Entries.persistentConnection)
        backend.removeObject(forKey: Entries.mace)
        backend.removeObject(forKey: Entries.vpnType)
        backend.removeObject(forKey: Entries.vpnCustomConfigurationMaps)
        backend.removeObject(forKey: Entries.visibleTiles)
        backend.removeObject(forKey: Entries.orderedTiles)
        backend.removeObject(forKey: Entries.historicalServers)
        backend.removeObject(forKey: Entries.cachedNetworks)
        backend.removeObject(forKey: Entries.nmtTrustedNetworkRules)
        backend.removeObject(forKey: Entries.nmtTemporaryOpenNetworks)
        backend.removeObject(forKey: Entries.nmtRulesEnabled)
        backend.removeObject(forKey: Entries.nmtGenericRules)
        backend.removeObject(forKey: Entries.nmtMigrationSuccess)
        backend.removeObject(forKey: Entries.trustCellularData)
        backend.removeObject(forKey: Entries.useWiFiProtection)
        backend.removeObject(forKey: Entries.trustedNetworks)
        backend.removeObject(forKey: Entries.ikeV2IntegrityAlgorithm)
        backend.removeObject(forKey: Entries.ikeV2EncryptionAlgorithm)
        backend.removeObject(forKey: Entries.ikeV2PacketSize)
        backend.removeObject(forKey: Entries.serverNetwork)
        backend.removeObject(forKey: Entries.signInWithAppleFakeEmail)
        backend.removeObject(forKey: Entries.shareServiceQualityData)
        backend.removeObject(forKey: Entries.versionWhenServiceQualityOpted)
        backend.synchronize()
    }

    func clear() {
        if let group = group {
            backend.removePersistentDomain(forName: group)
        } else {
            // FIXME: clear standard defaults
        }
    }
        
}
