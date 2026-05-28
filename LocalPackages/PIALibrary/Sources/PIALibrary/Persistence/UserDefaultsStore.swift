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

private let log = PIALogger.logger(for: UserDefaultsStore.self)

final class UserDefaultsStore: PlainStore, ConfigurationAccess {
    fileprivate enum Entry: String, CaseIterable {
        case username = "LoggedUsername"  // legacy

        case accountInfo = "LoggedAccountInfo"  // legacy

        case lastSignupEmail = "LastSignupEmail"

        case tokenMigrated = "TokenMigrated"

        case publicIP = "PublicIP"

        case lastServerCN = "LastServerCN"

        case historicalServers = "HistoricalServers"

        case cachedServers = "CachedServers"

        case serversConfiguration = "ServersConfiguration"

        case preferredServer = "CurrentRegion"  // legacy

        case lastConnectedRegion = "LastConnectedRegion"

        case preferredServerDIPToken = "CurrentRegionDIPToken"

        case pingByServerIdentifier = "PingByServerIdentifier"

        case vpnType = "VPNType"

        case vpnDisconnectsOnSleep = "VPNDisconnectsOnSleep"

        case vpnCustomConfigurationMaps = "VPNCustomConfigurationMaps"

        case lastKnownVpnStatus = "LastKnownVPNStatus"

        case persistentConnection = "PersistentConnection"  // legacy

        case showReconnectNotifications = "ShowReconnectNotifications"

        case mace = "MACE"  // legacy

        case visibleTiles = "VisibleTiles"

        case orderedTiles = "OrderedTiles"

        case useWiFiProtection = "UseWiFiProtection"

        case trustCellularData = "TrustCellularData"

        case nmtMigrationSuccess = "NMTMigrationSuccess"

        case trustedNetworks = "TrustedNetworks"

        case serverNetwork = "ServerNetwork"

        case ikeV2IntegrityAlgorithm = "IKEV2IntegrityAlgorithm"

        case ikeV2EncryptionAlgorithm = "IKEV2EncryptionAlgorithm"

        case ikeV2PacketSize = "IKEV2PacketSize"

        case signInWithAppleFakeEmail = "SignInWithAppleFakeEmail"

        case nmtRulesEnabled = "NMTRulesEnabled"

        case cachedNetworks = "CachedNetworks"

        case nmtTrustedNetworkRules = "NMTTrustedNetworkRules"

        case nmtTemporaryOpenNetworks = "NMTTemporaryOpenNetworks"

        case nmtGenericRules = "NMTGenericRules"

        case debugLogging = "DebugLogging"

        case shareServiceQualityData = "ShareServiceQualityData"

        case lastKnownException = "LastKnownException"

        case versionWhenServiceQualityOpted = "versionWhenServiceQualityOpted"

        case lastVPNConnectionAttempt = "lastVPNConnectionAttempt"

        case lastVPNConnectionSuccess = "lastVPNConnectionSuccess"

        case timeToConnectVPN = "timeToConnectVPN"

        case wireguardMigrationPerformed = "WireguardMigrationPerformed"

        case leakProtection = "LeakProtection"

        case allowLocalDeviceAccess = "AllowLocalDeviceAccess"

        case currentRFC1918VulnerableWifi = "CurrentRFC1918VulnerableWifi"
    }

    private let backend: UserDefaultsKeyed<Entry>

    private let group: String?

    private var historicalServersCopy: [Server]?

    private var cachedServersCopy: [Server]?

    private var visibleTilesCopy: [AvailableTiles]?

    private var orderedTilesCopy: [AvailableTiles]?

    private var serversConfigurationCopy: ServersBundle.Configuration?

    private var pingByServerIdentifier: [String: Int] = [:]
    private let pingQueue = DispatchQueue(label: "com.pia.userdefaultsstore.ping")

    init(group: String? = nil) {
        let backend = group.flatMap(UserDefaults.init(suiteName:)) ?? UserDefaults.standard
        self.backend = UserDefaultsKeyed(defaults: backend)
        self.group = group
        loadComplexMaps()
    }

    private func loadComplexMaps() {
        pingQueue.sync {
            pingByServerIdentifier = backend.dictionary(forKey: .pingByServerIdentifier) as? [String: Int] ?? [:]
        }
    }

    deinit {
        backend.synchronize()
    }

    // MARK: PlainStore

    // MARK: Account

    var publicUsername: String? {
        get {
            return backend.string(forKey: .username)
        }
        set {
            if let username = newValue {
                backend.set(username, forKey: .username)
            } else {
                backend.removeObject(forKey: .username)
            }
        }
    }

    var accountInfo: AccountInfo? {
        get {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            if let data = backend.data(forKey: .accountInfo) {
                do {
                    return try decoder.decode(AccountInfo.self, from: data)
                } catch {
                    log.warning("Failed to decode AccountInfo from stored data")
                    log.debug("AccountInfo decode error: \(error)")
                }
            }
            if let dict = backend.dictionary(forKey: .accountInfo),
                let data = try? JSONSerialization.data(withJSONObject: dict),
                let info = try? decoder.decode(AccountInfo.self, from: data)
            {
                return info
            }
            return nil
        }
        set {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            if let info = newValue, let data = try? encoder.encode(info) {
                backend.set(data, forKey: .accountInfo)
            } else {
                backend.removeObject(forKey: .accountInfo)
            }
        }
    }

    var lastSignupEmail: String? {
        get {
            return backend.string(forKey: .lastSignupEmail)
        }
        set {
            if let email = newValue {
                backend.set(email, forKey: .lastSignupEmail)
            } else {
                backend.removeObject(forKey: .lastSignupEmail)
            }
        }
    }

    var tokenMigrated: Bool {
        get {
            return backend.bool(forKey: .tokenMigrated)
        }
        set {
            backend.set(newValue, forKey: .tokenMigrated)
        }
    }

    var publicIP: String? {
        get {
            return backend.string(forKey: .publicIP)
        }
        set {
            if let publicIP = newValue {
                backend.set(publicIP, forKey: .publicIP)
            } else {
                backend.removeObject(forKey: .publicIP)
            }
        }
    }

    var lastServerCN: String? {
        get {
            return backend.string(forKey: .lastServerCN)
        }
        set {
            if let cn = newValue {
                backend.set(cn, forKey: .lastServerCN)
            } else {
                backend.removeObject(forKey: .lastServerCN)
            }
        }
    }

    var visibleTiles: [AvailableTiles] {
        get {
            if let copy = visibleTilesCopy {
                return copy
            }
            guard let intArray = backend.array(forKey: .visibleTiles) as? [Int] else {
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
            backend.set(intArray, forKey: .visibleTiles)
        }
    }

    var orderedTiles: [AvailableTiles] {
        get {
            if let copy = orderedTilesCopy {
                return copy
            }
            guard let intArray = backend.array(forKey: .orderedTiles) as? [Int] else {
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
            backend.set(intArray, forKey: .orderedTiles)
        }
    }

    // MARK: Server
    var historicalServers: [Server] {
        get {
            return readServers(key: .historicalServers, copy: historicalServersCopy)
        }
        set {
            var servers = newValue
            if servers.count > Client.configuration.maxQuickConnectServers {
                servers.removeFirst()
            }
            historicalServersCopy = servers
            backend.set(try? JSONEncoder().encode(servers), forKey: .historicalServers)
        }
    }

    var cachedServers: [Server] {
        get {
            return readServers(key: .cachedServers, copy: cachedServersCopy)
        }
        set {
            cachedServersCopy = newValue
            backend.set(try? JSONEncoder().encode(newValue), forKey: .cachedServers)
        }
    }

    private func readServers(key: Entry, copy: [Server]?) -> [Server] {
        if let copy { return copy }
        let decoder = JSONDecoder()
        if let data = backend.data(forKey: key) {
            do {
                return try decoder.decode([Server].self, from: data)
            } catch {
                log.warning("Failed to decode servers from stored data")
                log.debug("[Server] decode error: \(error)")
            }
        }
        if let jsonArray = backend.array(forKey: key) as? [[String: Any]] {
            return jsonArray.compactMap { dict in
                guard let data = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
                return try? decoder.decode(Server.self, from: data)
            }
        }
        return []
    }

    var preferredServer: Server? {
        get {
            let identifier = backend.string(forKey: .preferredServer)
            let dipToken = preferredServerDIPToken
            return cachedServers.first { $0.identifier == identifier && $0.dipToken == dipToken }
        }
        set {
            backend.set(newValue?.identifier, forKey: .preferredServer)
            backend.set(newValue?.dipToken, forKey: .preferredServerDIPToken)
            var lastServers = historicalServers
            if let server = newValue {

                let filtered = lastServers.filter({ $0.name == server.name })
                if filtered.count != 0,
                    let indexOfServer = lastServers.firstIndex(of: server)
                {
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
            let identifier = backend.string(forKey: .lastConnectedRegion)
            return cachedServers.first { $0.identifier == identifier }
        }
        set {
            backend.set(newValue?.identifier, forKey: .lastConnectedRegion)
        }
    }

    var preferredServerDIPToken: String? {
        get {
            return backend.string(forKey: .preferredServerDIPToken)
        }
        set {
            backend.set(newValue, forKey: .preferredServerDIPToken)
        }
    }

    func ping(forServerIdentifier serverIdentifier: String) -> Int? {
        return pingQueue.sync { pingByServerIdentifier[serverIdentifier] }
    }

    func setPing(_ ping: Int, forServerIdentifier serverIdentifier: String) {
        pingQueue.sync {
            if let currentResponseTime = pingByServerIdentifier[serverIdentifier] {
                if currentResponseTime > ping {
                    pingByServerIdentifier[serverIdentifier] = ping
                }
            } else {
                pingByServerIdentifier[serverIdentifier] = ping
            }
        }
    }

    func serializePings() {
        pingQueue.sync {
            backend.set(pingByServerIdentifier, forKey: .pingByServerIdentifier)
        }
    }

    func clearPings() {
        pingQueue.sync {
            pingByServerIdentifier.removeAll()
        }
    }

    // MARK: VPN

    var vpnType: String? {
        get {
            return backend.string(forKey: .vpnType)
        }
        set {
            backend.set(newValue, forKey: .vpnType)
        }
    }

    var vpnDisconnectsOnSleep: Bool {
        get {
            return backend.bool(forKey: .vpnDisconnectsOnSleep)
        }
        set {
            backend.set(newValue, forKey: .vpnDisconnectsOnSleep)
        }
    }

    var vpnCustomConfigurationMaps: [String: [String: Any]]? {
        get {
            return backend.dictionary(forKey: .vpnCustomConfigurationMaps) as? [String: [String: Any]]
        }
        set {
            backend.set(newValue, forKey: .vpnCustomConfigurationMaps)
        }
    }

    var lastKnownVpnStatus: VPNStatus {
        get {
            return VPNStatus(rawValue: backend.string(forKey: .lastKnownVpnStatus) ?? "") ?? .unknown
        }
        set {
            backend.set(newValue.rawValue, forKey: .lastKnownVpnStatus)
        }

    }

    var lastVPNConnectionAttempt: Double {
        get {
            return backend.double(forKey: .lastVPNConnectionAttempt)
        }
        set {
            backend.set(newValue, forKey: .lastVPNConnectionAttempt)
        }
    }

    var lastVPNConnectionSuccess: Double? {
        get {
            return backend.object(forKey: .lastVPNConnectionSuccess) as? Double
        }
        set {
            backend.set(newValue, forKey: .lastVPNConnectionSuccess)
        }
    }

    var timeToConnectVPN: Double {
        get {
            return backend.double(forKey: .timeToConnectVPN)
        }
        set {
            backend.set(newValue, forKey: .timeToConnectVPN)
        }
    }

    var wireguardMigrationPerformed: Bool {
        get {
            if backend.object(forKey: .wireguardMigrationPerformed) == nil {
                backend.set(false, forKey: .wireguardMigrationPerformed)
            }
            return backend.bool(forKey: .wireguardMigrationPerformed)
        }
        set {
            backend.set(newValue, forKey: .wireguardMigrationPerformed)
        }
    }

    var leakProtection: Bool {
        get {
            if backend.object(forKey: .leakProtection) == nil {
                backend.set(true, forKey: .leakProtection)
            }
            return backend.bool(forKey: .leakProtection)
        }
        set {
            backend.set(newValue, forKey: .leakProtection)
        }
    }

    var allowLocalDeviceAccess: Bool {
        get {
            if backend.object(forKey: .allowLocalDeviceAccess) == nil {
                backend.set(true, forKey: .allowLocalDeviceAccess)
            }
            return backend.bool(forKey: .allowLocalDeviceAccess)
        }
        set {
            backend.set(newValue, forKey: .allowLocalDeviceAccess)
        }
    }

    var currentRFC1918VulnerableWifi: String? {
        get {
            return backend.string(forKey: .currentRFC1918VulnerableWifi)
        }
        set {
            backend.set(newValue, forKey: .currentRFC1918VulnerableWifi)
        }
    }

    // MARK: Preferences

    var isPersistentConnection: Bool? {
        get {
            guard let value = backend.object(forKey: .persistentConnection) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .persistentConnection)
        }
    }

    var showReconnectNotifications: Bool? {
        get {
            guard let value = backend.object(forKey: .showReconnectNotifications) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .showReconnectNotifications)
        }
    }

    var ikeV2IntegrityAlgorithm: IKEv2IntegrityAlgorithm {
        get {
            guard let value = backend.object(forKey: .ikeV2IntegrityAlgorithm) as? String,
                let algorithm = IKEv2IntegrityAlgorithm(rawValue: value)
            else { return .default }
            return algorithm
        }
        set {
            backend.set(newValue.rawValue, forKey: .ikeV2IntegrityAlgorithm)
        }
    }

    var ikeV2EncryptionAlgorithm: IKEv2EncryptionAlgorithm {
        get {
            guard let value = backend.object(forKey: .ikeV2EncryptionAlgorithm) as? String,
                let algorithm = IKEv2EncryptionAlgorithm(rawValue: value)
            else { return .default }
            return algorithm
        }
        set {
            backend.set(newValue.rawValue, forKey: .ikeV2EncryptionAlgorithm)
        }
    }

    var ikeV2PacketSize: Int {
        get {
            guard let value = backend.object(forKey: .ikeV2PacketSize) as? Int else {
                return 0
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .ikeV2PacketSize)
        }
    }

    var nmtMigrationSuccess: Bool? {
        get {
            guard let value = backend.object(forKey: .nmtMigrationSuccess) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .nmtMigrationSuccess)
        }
    }

    var mace: Bool? {
        get {
            guard let value = backend.object(forKey: .mace) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .mace)
        }
    }

    var signInWithAppleFakeEmail: String? {
        get {
            return backend.string(forKey: .signInWithAppleFakeEmail)
        }
        set {
            backend.set(newValue, forKey: .signInWithAppleFakeEmail)
        }
    }

    // MARK: Service Quality

    var debugLogging: Bool? {
        get {
            return backend.bool(forKey: .debugLogging)
        }
        set {
            backend.set(newValue, forKey: .debugLogging)
        }
    }

    var shareServiceQualityData: Bool? {
        get {
            return backend.bool(forKey: .shareServiceQualityData)
        }
        set {
            backend.set(newValue, forKey: .shareServiceQualityData)
        }
    }

    var versionWhenServiceQualityOpted: String? {
        get {
            return backend.string(forKey: .versionWhenServiceQualityOpted)
        }
        set {
            backend.set(newValue, forKey: .versionWhenServiceQualityOpted)
        }
    }

    var lastKnownException: String? {
        get {
            return backend.string(forKey: .lastKnownException) ?? ""
        }
        set {
            backend.set(newValue, forKey: .lastKnownException)
        }
    }

    //MARK: Networks
    var cachedNetworks: [String] {
        get {
            guard let value = backend.object(forKey: .cachedNetworks) as? [String] else {
                return []
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .cachedNetworks)
        }
    }

    var nmtTrustedNetworkRules: [String: Int] {
        get {
            guard let value = backend.dictionary(forKey: .nmtTrustedNetworkRules) as? [String: Int] else {
                return [:]
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .nmtTrustedNetworkRules)
        }
    }

    var nmtTemporaryOpenNetworks: [String] {
        get {
            guard let value = backend.object(forKey: .nmtTemporaryOpenNetworks) as? [String] else {
                return []
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .nmtTemporaryOpenNetworks)
        }
    }

    var nmtGenericRules: [String: Int] {
        get {
            guard let value = backend.dictionary(forKey: .nmtGenericRules) as? [String: Int] else {
                return [:]
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .nmtGenericRules)
        }
    }

    var nmtRulesEnabled: Bool? {
        get {
            guard let value = backend.object(forKey: .nmtRulesEnabled) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .nmtRulesEnabled)
        }
    }

    ///Deprecated
    var trustCellularData: Bool? {
        get {
            guard let value = backend.object(forKey: .trustCellularData) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .trustCellularData)
        }
    }

    ///Deprecated
    var useWiFiProtection: Bool? {
        get {
            guard let value = backend.object(forKey: .useWiFiProtection) as? Bool else {
                return nil
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .useWiFiProtection)
        }
    }

    ///Deprecated
    var trustedNetworks: [String] {
        get {
            guard let value = backend.object(forKey: .trustedNetworks) as? [String] else {
                return []
            }
            return value
        }
        set {
            backend.set(newValue, forKey: .trustedNetworks)
        }
    }

    // MARK: Lifecycle

    func reset() {
        for entry in Entry.allCases {
            backend.removeObject(forKey: entry)
        }
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
