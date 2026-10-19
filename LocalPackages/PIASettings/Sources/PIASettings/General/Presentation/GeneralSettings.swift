//
//  GeneralSettings.swift
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

public enum GeneralSettings {}

extension GeneralSettings {
    public struct Preferences: Equatable, Sendable {
        public var showsServiceMessages: Bool
        public var showsGeoRegions: Bool

        public init(showsServiceMessages: Bool, showsGeoRegions: Bool) {
            self.showsServiceMessages = showsServiceMessages
            self.showsGeoRegions = showsGeoRegions
        }
    }

    public struct State: Equatable, Sendable {
        public var preferences: Preferences
        public var isResetConfirmationPresented = false

        public init(preferences: Preferences) {
            self.preferences = preferences
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case serviceMessagesToggled(Bool)
        case geoRegionsToggled(Bool)
        case connectSiriShortcutTapped
        case disconnectSiriShortcutTapped
        case resetTapped
        case resetConfirmationDismissed
        case resetConfirmed
        case preferencesLoaded(Preferences)
    }

    public struct Dependencies: Sendable {
        public let loadPreferences: @Sendable () -> Preferences
        public let preferencesChanges: @Sendable () -> AsyncStream<Void>
        public let setShowsServiceMessages: @Sendable (Bool) -> Void
        public let setShowsGeoRegions: @Sendable (Bool) -> Void
        public let resetToDefaults: @MainActor @Sendable () -> Void
        public let connectSiriShortcut: @Sendable () -> Void
        public let disconnectSiriShortcut: @Sendable () -> Void

        public init(
            loadPreferences: @Sendable @escaping () -> Preferences,
            preferencesChanges: @Sendable @escaping () -> AsyncStream<Void>,
            setShowsServiceMessages: @Sendable @escaping (Bool) -> Void,
            setShowsGeoRegions: @Sendable @escaping (Bool) -> Void,
            resetToDefaults: @MainActor @Sendable @escaping () -> Void,
            connectSiriShortcut: @Sendable @escaping () -> Void,
            disconnectSiriShortcut: @Sendable @escaping () -> Void,
        ) {
            self.loadPreferences = loadPreferences
            self.preferencesChanges = preferencesChanges
            self.setShowsServiceMessages = setShowsServiceMessages
            self.setShowsGeoRegions = setShowsGeoRegions
            self.resetToDefaults = resetToDefaults
            self.connectSiriShortcut = connectSiriShortcut
            self.disconnectSiriShortcut = disconnectSiriShortcut
        }
    }
}
