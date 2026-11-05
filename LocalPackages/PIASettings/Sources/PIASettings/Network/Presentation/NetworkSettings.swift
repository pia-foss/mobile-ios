//
//  NetworkSettings.swift
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

public enum NetworkSettings {}

extension NetworkSettings {
    public enum DNS: Hashable, Sendable {
        case preset(String)
        case custom
    }

    public struct Preferences: Equatable, Sendable {
        public var presets: [String]
        public var customServers: [String]
        public var dns: DNS

        public init(presets: [String], customServers: [String], dns: DNS) {
            self.presets = presets
            self.customServers = customServers
            self.dns = dns
        }
    }

    public struct State: Equatable, Sendable {
        public var preferences: Preferences
        public var isEditable: Bool
        public var isCustomDNSWarningPresented = false

        public init(preferences: Preferences, isEditable: Bool) {
            self.preferences = preferences
            self.isEditable = isEditable
        }

        var dnsOptions: [DNS] {
            preferences.presets.map(DNS.preset) + [.custom]
        }

        var hasCustomDNS: Bool {
            !preferences.customServers.isEmpty
        }

        var customDNSValue: String? {
            hasCustomDNS ? preferences.customServers.joined(separator: " / ") : nil
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case dnsSelected(DNS)
        case customDNSTapped
        case customDNSWarningConfirmed
        case customDNSWarningDismissed
        case preferencesLoaded(Preferences)
    }

    public struct Dependencies: Sendable {
        public let loadPreferences: @MainActor @Sendable () -> Preferences
        public let isEditable: @MainActor @Sendable () -> Bool
        public let preferencesChanges: @Sendable () -> AsyncStream<Void>
        public let setDNS: @MainActor @Sendable (DNS) -> Void
        public let showCustomDNS: @MainActor @Sendable () -> Void

        public init(
            loadPreferences: @MainActor @Sendable @escaping () -> Preferences,
            isEditable: @MainActor @Sendable @escaping () -> Bool,
            preferencesChanges: @Sendable @escaping () -> AsyncStream<Void>,
            setDNS: @MainActor @Sendable @escaping (DNS) -> Void,
            showCustomDNS: @MainActor @Sendable @escaping () -> Void,
        ) {
            self.loadPreferences = loadPreferences
            self.isEditable = isEditable
            self.preferencesChanges = preferencesChanges
            self.setDNS = setDNS
            self.showCustomDNS = showCustomDNS
        }
    }
}
