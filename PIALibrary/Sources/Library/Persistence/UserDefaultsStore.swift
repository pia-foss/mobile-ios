//
//  UserDefaultsStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Gloss
import SwiftyBeaver

private let log = SwiftyBeaver.self

class UserDefaultsStore: PlainStore, ConfigurationAccess {
    private struct Entries {
        static let username = "LoggedUsername" // legacy
        
        static let accountInfo = "LoggedAccountInfo" // legacy

        static let lastSignupEmail = "LastSignupEmail"
        
        static let publicIP = "PublicIP"

        static let historicalServers = "HistoricalServers"

        static let cachedServers = "CachedServers"

        static let serversConfiguration = "ServersConfiguration"
        
        static let preferredServer = "CurrentRegion" // legacy

        static let pingByServerIdentifier = "PingByServerIdentifier"
        
        static let vpnType = "VPNType"
        
        static let vpnDisconnectsOnSleep = "VPNDisconnectsOnSleep"
        
        static let vpnCustomConfigurationMaps = "VPNCustomConfigurationMaps"

        static let persistentConnection = "PersistentConnection" // legacy

        static let mace = "MACE" // legacy
        
        static let visibleTiles = "VisibleTiles"

        static let orderedTiles = "OrderedTiles"

        static let useWiFiProtection = "UseWiFiProtection"

        static let trustCellularData = "TrustCellularData"

        static let authMigrationSuccess = "AuthenticationTokenMigrationSuccess"

        static let shouldConnectForAllNetworks = "ShouldConnectForAllNetworks"

        static let cachedNetworks = "CachedNetworks"

        static let trustedNetworks = "TrustedNetworks"
        
        static let disconnectOnTrusted = "DisconnectOnTrusted"

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
            return cachedServers.first { $0.identifier == identifier }
        }
        set {
            backend.set(newValue?.identifier, forKey: Entries.preferredServer)
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
    
    func ping(forServerIdentifier serverIdentifier: String) -> Int? {
        return pingByServerIdentifier[serverIdentifier]
    }
    
    func setPing(_ ping: Int, forServerIdentifier serverIdentifier: String) {
        pingByServerIdentifier[serverIdentifier] = ping
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

    var authMigrationSuccess: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.authMigrationSuccess) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.authMigrationSuccess)
        }
    }
    
    var shouldConnectForAllNetworks: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.shouldConnectForAllNetworks) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.shouldConnectForAllNetworks)
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

    var disconnectOnTrusted: Bool? {
        get {
            guard let value = backend.object(forKey: Entries.disconnectOnTrusted) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: Entries.disconnectOnTrusted)
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
        backend.removeObject(forKey: Entries.trustedNetworks)
        backend.removeObject(forKey: Entries.disconnectOnTrusted)
        backend.removeObject(forKey: Entries.shouldConnectForAllNetworks)
        backend.removeObject(forKey: Entries.useWiFiProtection)
        backend.removeObject(forKey: Entries.trustCellularData)
        backend.removeObject(forKey: Entries.authMigrationSuccess)
        backend.removeObject(forKey: Entries.disconnectOnTrusted)
        backend.synchronize()
    }

    func clear() {
        if let group = group {
            backend.removePersistentDomain(forName: group)
        } else {
            // FIXME: clear standard defaults
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

    //MARK: Networks
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

}
