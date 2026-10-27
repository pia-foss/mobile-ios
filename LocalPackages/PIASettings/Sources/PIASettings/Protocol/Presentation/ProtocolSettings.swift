//
//  ProtocolSettings.swift
//  PIASettings
//
//  Copyright © 2026 Private Internet Access, Inc.
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

public enum ProtocolSettings {}

extension ProtocolSettings {
    public enum VPNProtocol: CaseIterable, Sendable {
        case automatic
        case wireGuard
        case openVPN
    }

    public enum Transport: CaseIterable, Sendable {
        case automatic
        case udp
        case tcp
    }

    public static let automaticPort: UInt16 = 0

    public struct Preferences: Equatable, Sendable {
        public var vpnProtocol: VPNProtocol
        public var transport: Transport
        public var remotePort: UInt16
        public var cipher: String
        public var usesSmallPackets: Bool

        public init(
            vpnProtocol: VPNProtocol,
            transport: Transport,
            remotePort: UInt16,
            cipher: String,
            usesSmallPackets: Bool
        ) {
            self.vpnProtocol = vpnProtocol
            self.transport = transport
            self.remotePort = remotePort
            self.cipher = cipher
            self.usesSmallPackets = usesSmallPackets
        }
    }

    public struct Options: Equatable, Sendable {
        public var udpPorts: [UInt16]
        public var tcpPorts: [UInt16]
        public var ciphers: [String]
        public var isCipherEditable: Bool

        public init(udpPorts: [UInt16], tcpPorts: [UInt16], ciphers: [String], isCipherEditable: Bool) {
            self.udpPorts = udpPorts.sorted()
            self.tcpPorts = tcpPorts.sorted()
            self.ciphers = ciphers
            self.isCipherEditable = isCipherEditable
        }
    }

    enum Row: Hashable, Sendable {
        case vpnProtocol
        case transport
        case remotePort(isEnabled: Bool)
        case dataEncryption(isEditable: Bool)
        case handshake
        case smallPackets
    }

    public struct State: Equatable, Sendable {
        public var preferences: Preferences
        public var options: Options

        public init(preferences: Preferences, options: Options) {
            self.preferences = preferences
            self.options = options
        }

        var rows: [Row] {
            switch preferences.vpnProtocol {
            case .automatic:
                [.vpnProtocol, .smallPackets]
            case .wireGuard:
                [.vpnProtocol, .dataEncryption(isEditable: false), .handshake, .smallPackets]
            case .openVPN:
                [
                    .vpnProtocol,
                    .transport,
                    .remotePort(isEnabled: preferences.transport != .automatic),
                    .dataEncryption(isEditable: options.isCipherEditable),
                    .handshake,
                    .smallPackets
                ]
            }
        }

        var remotePorts: [UInt16] {
            switch preferences.transport {
            case .automatic: [automaticPort]
            case .udp: [automaticPort] + options.udpPorts
            case .tcp: [automaticPort] + options.tcpPorts
            }
        }

        var dataEncryption: String {
            preferences.vpnProtocol == .wireGuard ? "ChaCha20" : preferences.cipher
        }

        var handshake: String {
            preferences.vpnProtocol == .wireGuard ? "Noise_IK" : "RSA-4096"
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case vpnProtocolSelected(VPNProtocol)
        case transportSelected(Transport)
        case remotePortSelected(UInt16)
        case cipherSelected(String)
        case smallPacketsToggled(Bool)
        case preferencesLoaded(Preferences)
    }

    public struct Dependencies: Sendable {
        public let loadPreferences: @MainActor @Sendable () -> Preferences
        public let loadOptions: @MainActor @Sendable () -> Options
        public let preferencesChanges: @Sendable () -> AsyncStream<Void>
        public let setVPNProtocol: @MainActor @Sendable (VPNProtocol) -> Void
        public let setTransport: @MainActor @Sendable (Transport) -> Void
        public let setRemotePort: @MainActor @Sendable (UInt16) -> Void
        public let setCipher: @MainActor @Sendable (String) -> Void
        public let setUsesSmallPackets: @MainActor @Sendable (Bool) -> Void

        public init(
            loadPreferences: @MainActor @Sendable @escaping () -> Preferences,
            loadOptions: @MainActor @Sendable @escaping () -> Options,
            preferencesChanges: @Sendable @escaping () -> AsyncStream<Void>,
            setVPNProtocol: @MainActor @Sendable @escaping (VPNProtocol) -> Void,
            setTransport: @MainActor @Sendable @escaping (Transport) -> Void,
            setRemotePort: @MainActor @Sendable @escaping (UInt16) -> Void,
            setCipher: @MainActor @Sendable @escaping (String) -> Void,
            setUsesSmallPackets: @MainActor @Sendable @escaping (Bool) -> Void,
        ) {
            self.loadPreferences = loadPreferences
            self.loadOptions = loadOptions
            self.preferencesChanges = preferencesChanges
            self.setVPNProtocol = setVPNProtocol
            self.setTransport = setTransport
            self.setRemotePort = setRemotePort
            self.setCipher = setCipher
            self.setUsesSmallPackets = setUsesSmallPackets
        }
    }
}
