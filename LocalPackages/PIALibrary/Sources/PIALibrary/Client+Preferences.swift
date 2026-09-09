//
//  Client+Preferences.swift
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

private let log = PIALogger.logger(for: Client.Preferences.self)

private protocol PreferencesStore: AnyObject {
    var preferredServer: Server? { get set }

    var lastConnectedRegion: Server? { get set }

    var isPersistentConnection: Bool { get set }

    var showReconnectNotifications: Bool { get set }

    var useWiFiProtection: Bool { get set }

    var trustCellularData: Bool { get set }

    var nmtMigrationSuccess: Bool { get set }

    var vpnType: String { get set }

    var vpnDisconnectsOnSleep: Bool { get set }

    var availableNetworks: [String] { get set }

    var trustedNetworks: [String] { get set }

    var nmtTrustedNetworkRules: [String: Int] { get set }

    var nmtTemporaryOpenNetworks: [String] { get set }

    var nmtGenericRules: [String: Int] { get set }

    var nmtRulesEnabled: Bool { get set }

    var useSmallPackets: Bool { get set }

    var openVPNSocketType: String? { get set }

    var openVPNCipher: String? { get set }

    var openVPNAuth: String? { get set }

    var openVPNPort: Int { get set }

    var openVPNDnsServers: [String] { get set }

    var wireGuardDnsServers: [String] { get set }

    var signInWithAppleFakeEmail: String? { get set }

    var debugLogging: Bool { get set }

    var shareServiceQualityData: Bool { get set }

    var lastKnownException: String? { get set }

    var versionWhenServiceQualityOpted: String? { get set }

    var hasRespondedToServiceQualityConsent: Bool { get set }

}

private extension PreferencesStore {
    func load(from source: PreferencesStore) {
        preferredServer = source.preferredServer
        isPersistentConnection = source.isPersistentConnection
        useWiFiProtection = source.useWiFiProtection
        trustCellularData = source.trustCellularData
        nmtMigrationSuccess = source.nmtMigrationSuccess
        vpnType = source.vpnType
        vpnDisconnectsOnSleep = source.vpnDisconnectsOnSleep
        availableNetworks = source.availableNetworks
        trustedNetworks = source.trustedNetworks
        nmtTrustedNetworkRules = source.nmtTrustedNetworkRules
        nmtTemporaryOpenNetworks = source.nmtTemporaryOpenNetworks
        nmtGenericRules = source.nmtGenericRules
        nmtRulesEnabled = source.nmtRulesEnabled
        useSmallPackets = source.useSmallPackets
        openVPNSocketType = source.openVPNSocketType
        openVPNCipher = source.openVPNCipher
        openVPNAuth = source.openVPNAuth
        openVPNPort = source.openVPNPort
        openVPNDnsServers = source.openVPNDnsServers
        wireGuardDnsServers = source.wireGuardDnsServers
        signInWithAppleFakeEmail = source.signInWithAppleFakeEmail
        lastKnownException = source.lastKnownException
        lastConnectedRegion = source.lastConnectedRegion

        // Skipped because they are committed immediately when changed:
        // - showReconnectNotifications
        // - debugLogging
        // - shareServiceQualityData
        // - versionWhenServiceQualityOpted
        // - hasRespondedToServiceQualityConsent
    }
}

extension Client {

    /// The persistent preferences of the client.
    public final class Preferences: PreferencesStore, ConfigurationAccess, DatabaseAccess {

        /// The default preferences (editable).
        public var defaults = Editable()

        /**
         Returns an editable object for preferences modification.

         - Returns: An `Editable` object for preferences modification.
         */
        public func editable() -> Editable {
            let copy = Editable()
            copy.load(from: self)
            copy.target = self
            return copy
        }

        // MARK: PreferencesStore

        /// The preferred `Server`.
        public fileprivate(set) var preferredServer: Server? {
            get {
                return accessedDatabase.plain.preferredServer
            }
            set {
                accessedDatabase.plain.preferredServer = newValue
            }
        }

        public fileprivate(set) var lastConnectedRegion: Server? {
            get {
                return accessedDatabase.plain.lastConnectedRegion
            }
            set {
                accessedDatabase.plain.lastConnectedRegion = newValue
            }
        }

        /// Enables automatic VPN reconnection.
        public fileprivate(set) var isPersistentConnection: Bool {
            get {
                return accessedDatabase.plain.isPersistentConnection ?? defaults.isPersistentConnection
            }
            set {
                accessedDatabase.plain.isPersistentConnection = newValue
            }
        }

        /// Enables automatic VPN reconnection.
        public fileprivate(set) var showReconnectNotifications: Bool {
            get {
                return accessedDatabase.plain.showReconnectNotifications ?? defaults.showReconnectNotifications
            }
            set {
                accessedDatabase.plain.showReconnectNotifications = newValue
            }
        }

        /// Use VPN WiFi Protection
        public fileprivate(set) var useWiFiProtection: Bool {
            get {
                return accessedDatabase.plain.useWiFiProtection ?? defaults.useWiFiProtection
            }
            set {
                accessedDatabase.plain.useWiFiProtection = newValue
            }
        }

        /// Trust cellular data
        public fileprivate(set) var trustCellularData: Bool {
            get {
                return accessedDatabase.plain.trustCellularData ?? defaults.trustCellularData
            }
            set {
                accessedDatabase.plain.trustCellularData = newValue
            }
        }

        /// Flag to indicate if we have migrated the nmt rules
        public fileprivate(set) var nmtMigrationSuccess: Bool {
            get {
                return accessedDatabase.plain.nmtMigrationSuccess ?? defaults.nmtMigrationSuccess
            }
            set {
                accessedDatabase.plain.nmtMigrationSuccess = newValue
            }
        }

        /// The type of the current VPN profile. Must be found in `Client.Configuration.availableVPNTypes(...)`.
        ///
        /// - Seealso: `VPNProfile.vpnType`
        /// - Seealso: `Client.Configuration.availableVPNTypes(...)`
        public fileprivate(set) var vpnType: String {
            get {
                return accessedDatabase.plain.vpnType ?? defaults.vpnType
            }
            set {
                accessedDatabase.plain.vpnType = newValue
            }
        }

        /// When device sleeps, disconnects from the VPN if `true`.
        public fileprivate(set) var vpnDisconnectsOnSleep: Bool {
            get {
                return accessedDatabase.plain.vpnDisconnectsOnSleep
            }
            set {
                accessedDatabase.plain.vpnDisconnectsOnSleep = newValue
            }
        }

        /// "Use Small Packets" — a single user-facing setting applied to whichever protocol
        /// (OpenVPN or WireGuard) ends up connecting, including under automatic negotiation.
        public fileprivate(set) var useSmallPackets: Bool {
            get {
                return accessedDatabase.plain.useSmallPackets
            }
            set {
                accessedDatabase.plain.useSmallPackets = newValue
            }
        }

        /// The OpenVPN transport (`AppConstants.OpenVPNSocketType` raw value); `nil` means automatic.
        public fileprivate(set) var openVPNSocketType: String? {
            get {
                return accessedDatabase.plain.openVPNSocketType
            }
            set {
                accessedDatabase.plain.openVPNSocketType = newValue
            }
        }

        /// The OpenVPN cipher (`OpenVPN.Cipher` raw value, e.g. "AES-128-GCM").
        public fileprivate(set) var openVPNCipher: String? {
            get {
                return accessedDatabase.plain.openVPNCipher
            }
            set {
                accessedDatabase.plain.openVPNCipher = newValue
            }
        }

        /// The OpenVPN auth digest (raw value, e.g. "SHA256").
        public fileprivate(set) var openVPNAuth: String? {
            get {
                return accessedDatabase.plain.openVPNAuth
            }
            set {
                accessedDatabase.plain.openVPNAuth = newValue
            }
        }

        /// The OpenVPN remote port; `0` means automatic.
        public fileprivate(set) var openVPNPort: Int {
            get {
                return accessedDatabase.plain.openVPNPort
            }
            set {
                accessedDatabase.plain.openVPNPort = newValue
            }
        }

        /// Custom DNS resolvers for OpenVPN (the Settings → Network choice); empty means server-provided.
        public fileprivate(set) var openVPNDnsServers: [String] {
            get {
                return accessedDatabase.plain.openVPNDnsServers
            }
            set {
                accessedDatabase.plain.openVPNDnsServers = newValue
            }
        }

        /// Custom DNS resolvers for WireGuard (the Settings → Network choice); empty means server-provided.
        public fileprivate(set) var wireGuardDnsServers: [String] {
            get {
                return accessedDatabase.plain.wireGuardDnsServers
            }
            set {
                accessedDatabase.plain.wireGuardDnsServers = newValue
            }
        }

        /// The `String` array of available WiFi networks
        public fileprivate(set) var availableNetworks: [String] {
            get {
                return accessedDatabase.plain.cachedNetworks
            }
            set {
                accessedDatabase.plain.cachedNetworks = newValue
            }
        }

        /// The `String` array of trusted WiFi networks
        public fileprivate(set) var trustedNetworks: [String] {
            get {
                return accessedDatabase.plain.trustedNetworks
            }
            set {
                accessedDatabase.plain.trustedNetworks = newValue
            }
        }

        /// The `String:Int` dictionary of trusted WiFi networks with the rule to apply
        public fileprivate(set) var nmtTrustedNetworkRules: [String: Int] {
            get {
                return accessedDatabase.plain.nmtTrustedNetworkRules
            }
            set {
                accessedDatabase.plain.nmtTrustedNetworkRules = newValue
            }
        }

        /// The `String` array of temporary open networks whee the user is trying to connect
        public fileprivate(set) var nmtTemporaryOpenNetworks: [String] {
            get {
                return accessedDatabase.plain.nmtTemporaryOpenNetworks
            }
            set {
                accessedDatabase.plain.nmtTemporaryOpenNetworks = newValue
            }
        }

        /// The `Int:Int` dictionary of generic rules for each type of network
        public fileprivate(set) var nmtGenericRules: [String: Int] {
            get {
                return accessedDatabase.plain.nmtGenericRules
            }
            set {
                accessedDatabase.plain.nmtGenericRules = newValue
            }
        }

        /// Disconnect the VPN when joining a trusted network. False by default
        public fileprivate(set) var nmtRulesEnabled: Bool {
            get {
                return accessedDatabase.plain.nmtRulesEnabled ?? false
            }
            set {
                accessedDatabase.plain.nmtRulesEnabled = newValue
            }
        }

        /// Sign in with Apple generates only once the fake email. We store it just in case the user tries to use it multiple time
        public fileprivate(set) var signInWithAppleFakeEmail: String? {
            get {
                return accessedDatabase.plain.signInWithAppleFakeEmail
            }
            set {
                accessedDatabase.plain.signInWithAppleFakeEmail = newValue
            }
        }

        /// Store a date as a number when last VPN Connection was attempted.
        public var lastVPNConnectionAttempt: Double {
            get {
                return accessedDatabase.plain.lastVPNConnectionAttempt
            }
            set {
                accessedDatabase.plain.lastVPNConnectionAttempt = newValue
            }
        }

        /// Store a date as a number when last VPN Connection has succeeded.
        public var lastVPNConnectionSuccess: Double? {
            get {
                return accessedDatabase.plain.lastVPNConnectionSuccess
            }
            set {
                accessedDatabase.plain.lastVPNConnectionSuccess = newValue
            }
        }

        /// Store a decimal number which represents time (in seconds) between
        /// connecting and connect state of VPNDaemon
        public var timeToConnectVPN: Double {
            get {
                return accessedDatabase.plain.timeToConnectVPN
            }
            set {
                accessedDatabase.plain.timeToConnectVPN = newValue
            }
        }

        /// Store a bool that represents whether we already attempted to migrate to wireguard
        public var wireguardMigrationPerformed: Bool {
            get {
                return accessedDatabase.plain.wireguardMigrationPerformed
            }
            set {
                accessedDatabase.plain.wireguardMigrationPerformed = newValue
            }
        }

        /// Store a bool that represents the status of leak protection property
        public var leakProtection: Bool {
            get {
                return accessedDatabase.plain.leakProtection
            }
            set {
                accessedDatabase.plain.leakProtection = newValue
            }
        }

        /// Store a bool that represents the status of allowLocalDeviceAccess property
        public var allowLocalDeviceAccess: Bool {
            get {
                return accessedDatabase.plain.allowLocalDeviceAccess
            }
            set {
                accessedDatabase.plain.allowLocalDeviceAccess = newValue
            }
        }

        /// If the current connected WIFI is a RFC1918 vulnerable WIFI it stores the name, otherwise it returns nil
        public var currentRFC1918VulnerableWifi: String? {
            get {
                return accessedDatabase.plain.currentRFC1918VulnerableWifi
            }
            set {
                accessedDatabase.plain.currentRFC1918VulnerableWifi = newValue
            }
        }

        // MARK: Service Quality

        /// Shares anonymous data to the service quality library.
        public var debugLogging: Bool {
            get {
                return accessedDatabase.plain.debugLogging ?? false
            }
            set {
                accessedDatabase.plain.debugLogging = newValue
            }
        }

        /// Shares anonymous data to the service quality library.
        public fileprivate(set) var shareServiceQualityData: Bool {
            get {
                return accessedDatabase.plain.shareServiceQualityData ?? false
            }
            set {
                accessedDatabase.plain.shareServiceQualityData = newValue
            }
        }

        /// Whether `shareServiceQualityData` has ever been explicitly written, either way.
        /// Unlike `shareServiceQualityData` itself (which collapses an unset value to `false`),
        /// this distinguishes "never asked" from an explicit accept/reject — needed to migrate
        /// users who already answered the legacy share-data panel before
        /// `hasRespondedToServiceQualityConsent` existed.
        public var hasExplicitShareServiceQualityDataValue: Bool {
            return accessedDatabase.plain.shareServiceQualityData != nil
        }

        /// Store app version when user opted-in for service quality stats
        public var versionWhenServiceQualityOpted: String? {
            get {
                return accessedDatabase.plain.versionWhenServiceQualityOpted
            }
            set {
                accessedDatabase.plain.versionWhenServiceQualityOpted = newValue
            }
        }

        /// Whether the user has already responded (accept or reject) to the service-quality
        /// share-data consent prompt, regardless of which way they answered.
        public fileprivate(set) var hasRespondedToServiceQualityConsent: Bool {
            get {
                return accessedDatabase.plain.hasRespondedToServiceQualityConsent ?? false
            }
            set {
                accessedDatabase.plain.hasRespondedToServiceQualityConsent = newValue
            }
        }

        /// Stores last known exception raised by the app at any point
        public var lastKnownException: String? {
            get {
                return accessedDatabase.plain.lastKnownException
            }
            set {
                accessedDatabase.plain.lastKnownException = newValue
            }
        }
    }
}

// MARK: Editable
extension Client.Preferences {

    /// Provides a means to edit `Client.Preferences` in a buffered way. Changes can be committed or reverted.
    public class Editable: PreferencesStore {

        fileprivate var target: Client.Preferences?

        fileprivate init() {
            preferredServer = nil
            lastConnectedRegion = nil
            isPersistentConnection = true
            useWiFiProtection = true
            trustCellularData = false
            nmtMigrationSuccess = false

            // Both platforms connect through the PlatformSDK tunnel, whose protocol this preference
            // selects; automatic negotiation is the default.
            vpnType = KapePlatformSDKVPNType.automatic.rawValue

            vpnDisconnectsOnSleep = false
            availableNetworks = []
            trustedNetworks = []
            nmtTrustedNetworkRules = [:]
            nmtTemporaryOpenNetworks = []
            nmtGenericRules = [
                NMTType.protectedWiFi.rawValue: NMTRules.alwaysConnect.rawValue,
                NMTType.openWiFi.rawValue: NMTRules.alwaysConnect.rawValue,
                NMTType.cellular.rawValue: NMTRules.alwaysConnect.rawValue
            ]
            nmtRulesEnabled = false
            useSmallPackets = false
            openVPNSocketType = nil
            openVPNCipher = nil
            openVPNAuth = nil
            openVPNPort = 0
            openVPNDnsServers = []
            wireGuardDnsServers = []
            signInWithAppleFakeEmail = nil
            lastKnownException = nil

            // Computed properties (immediate commit), not initialized here
            // - showReconnectNotifications
            // - debugLogging
            // - shareServiceQualityData
            // - versionWhenServiceQualityOpted
            // - hasRespondedToServiceQualityConsent
        }

        /**
         Commits the changes to the preferences.
         */
        public func commit() {
            target?.load(from: self)
        }

        /**
         Resets the preferences to factory defaults.

         - Returns: `self`
         - Seealso: `Client.Preferences.defaults`
         */
        @discardableResult public func reset() -> Self {
            guard let target = target else {
                return self
            }
            load(from: target.defaults)
            return self
        }

        // MARK: PreferencesStore

        /// :nodoc:
        public var preferredServer: Server?

        /// :nodoc:
        public var lastConnectedRegion: Server?

        /// :nodoc:
        public var isPersistentConnection: Bool

        /// :nodoc: Commits immediately when set
        public var showReconnectNotifications: Bool {
            get {
                return target?.showReconnectNotifications ?? true
            }
            set {
                target?.showReconnectNotifications = newValue
            }
        }

        /// :nodoc:
        public var useWiFiProtection: Bool

        /// :nodoc:
        public var trustCellularData: Bool

        /// :nodoc:
        public var nmtMigrationSuccess: Bool

        /// :nodoc:
        public var vpnType: String

        /// :nodoc:
        public var vpnDisconnectsOnSleep: Bool

        /// :nodoc:
        /// :nodoc:
        public var availableNetworks: [String]

        /// :nodoc:
        public var trustedNetworks: [String]

        /// :nodoc:
        public var nmtTrustedNetworkRules: [String: Int]

        /// :nodoc:
        public var nmtTemporaryOpenNetworks: [String]

        /// :nodoc:
        public var nmtGenericRules: [String: Int]

        /// :nodoc:
        public var nmtRulesEnabled: Bool

        /// :nodoc:
        public var useSmallPackets: Bool

        /// :nodoc:
        public var openVPNSocketType: String?

        /// :nodoc:
        public var openVPNCipher: String?

        public var openVPNAuth: String?

        /// :nodoc:
        public var openVPNPort: Int

        /// :nodoc:
        public var openVPNDnsServers: [String]

        /// :nodoc:
        public var wireGuardDnsServers: [String]

        /// :nodoc:
        public var signInWithAppleFakeEmail: String?

        /// :nodoc: Commits immediately when set
        public var debugLogging: Bool {
            get {
                return target?.debugLogging ?? false
            }
            set {
                target?.debugLogging = newValue
            }
        }

        /// :nodoc: Commits immediately when set
        public var shareServiceQualityData: Bool {
            get {
                return target?.shareServiceQualityData ?? false
            }
            set {
                target?.shareServiceQualityData = newValue
            }
        }

        /// :nodoc: Commits immediately when set
        public var versionWhenServiceQualityOpted: String? {
            get {
                return target?.versionWhenServiceQualityOpted
            }
            set {
                target?.versionWhenServiceQualityOpted = newValue
            }
        }

        /// :nodoc: Commits immediately when set
        public var hasRespondedToServiceQualityConsent: Bool {
            get {
                return target?.hasRespondedToServiceQualityConsent ?? false
            }
            set {
                target?.hasRespondedToServiceQualityConsent = newValue
            }
        }

        /// :nodoc:
        public var lastKnownException: String?

        // MARK: Required actions

        /**
         Returns the action required to make the pending changes effective for the current VPN profile.

         - Returns: A `VPNAction` or `nil` if no action is required.
         */
        public func requiredVPNAction() -> VPNAction? {
            guard let target = target else {
                return nil
            }

            var queue: [VPNAction] = []
            if (isPersistentConnection != target.isPersistentConnection) {
                queue.append(VPNActionReinstall())
            }
            if (availableNetworks != target.availableNetworks) {
                queue.append(VPNActionDisconnectAndReinstall())
            }
            if (nmtTrustedNetworkRules != target.nmtTrustedNetworkRules) {
                queue.append(VPNActionDisconnectAndReinstall())
            }
            if (nmtGenericRules != target.nmtGenericRules) {
                queue.append(VPNActionDisconnectAndReinstall())
            }
            if (nmtRulesEnabled != target.nmtRulesEnabled) {
                queue.append(VPNActionDisconnectAndReinstall())
            }
            if (vpnDisconnectsOnSleep != target.vpnDisconnectsOnSleep) {
                queue.append(VPNActionReinstall())
            }
            if !isPreferredServer(equalTo: target.preferredServer) {
                queue.append(VPNActionReinstall())
            }
            if (vpnType != target.vpnType) {
                queue.append(VPNActionDisconnectAndReinstall())
            }
            if (useSmallPackets != target.useSmallPackets) {
                queue.append(VPNActionReinstall())
            }
            if (openVPNSocketType != target.openVPNSocketType) {
                queue.append(VPNActionReinstall())
            }
            if (openVPNCipher != target.openVPNCipher) {
                queue.append(VPNActionReinstall())
            }
            if (openVPNAuth != target.openVPNAuth) {
                queue.append(VPNActionReinstall())
            }
            if (openVPNPort != target.openVPNPort) {
                queue.append(VPNActionReinstall())
            }
            if (openVPNDnsServers != target.openVPNDnsServers) {
                queue.append(VPNActionReinstall())
            }
            if (wireGuardDnsServers != target.wireGuardDnsServers) {
                queue.append(VPNActionReinstall())
            }
            return queue.max { $0.priority < $1.priority }
        }

        public func defaultVPNAction() -> VPNAction? {
            return VPNActionDisconnectAndReinstall()
        }

        private func isPreferredServer(equalTo server: Server?) -> Bool {
            guard let preferredServer = preferredServer else {
                return (server == nil)
            }
            guard let server = server else {
                return false
            }
            return (preferredServer == server)
        }

        /**
         Returns `true` if the VPN needs to reconnect to make the pending changes effective.

         - Returns: `true` if the VPN needs reconnection.
         */
        public func suggestsVPNReconnection() -> Bool {
            guard let target = target else {
                return false
            }
            if (isPersistentConnection != target.isPersistentConnection) {
                return true
            }
            if (useSmallPackets != target.useSmallPackets) {
                return true
            }
            if (openVPNSocketType != target.openVPNSocketType) {
                return true
            }
            if (openVPNCipher != target.openVPNCipher) {
                return true
            }
            if (openVPNAuth != target.openVPNAuth) {
                return true
            }
            if (openVPNPort != target.openVPNPort) {
                return true
            }
            if (openVPNDnsServers != target.openVPNDnsServers) {
                return true
            }
            if (wireGuardDnsServers != target.wireGuardDnsServers) {
                return true
            }
            return false
        }
    }
}
