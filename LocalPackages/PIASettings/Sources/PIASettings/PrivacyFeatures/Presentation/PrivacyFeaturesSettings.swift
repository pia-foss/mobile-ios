//
//  PrivacyFeaturesSettings.swift
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

public enum PrivacyFeaturesSettings {}

extension PrivacyFeaturesSettings {
    public struct Preferences: Equatable, Sendable {
        public var killSwitch: Bool
        public var reconnectNotifications: Bool

        public init(killSwitch: Bool, reconnectNotifications: Bool) {
            self.killSwitch = killSwitch
            self.reconnectNotifications = reconnectNotifications
        }
    }

    public struct State: Equatable, Sendable {
        public var preferences: Preferences
        public let isAutomationEnabled: Bool
        public var isContentBlockerEnabled = false
        public var isRefreshingBlockList = false
        public var isKillSwitchWarningPresented = false

        public init(preferences: Preferences, isAutomationEnabled: Bool) {
            self.preferences = preferences
            self.isAutomationEnabled = isAutomationEnabled
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case preferencesLoaded(Preferences)
        case killSwitchToggled(Bool)
        case killSwitchWarningConfirmed
        case killSwitchWarningDismissed
        case reconnectNotificationsToggled(Bool)
        case contentBlockerToggled
        case contentBlockerStateLoaded(Bool)
        case refreshBlockListTapped
        case blockListRefreshed
    }

    public struct Dependencies: Sendable {
        public let loadPreferences: @MainActor @Sendable () -> Preferences
        public let isAutomationEnabled: @MainActor @Sendable () -> Bool
        public let preferencesChanges: @Sendable () -> AsyncStream<Void>
        public let savePreferences: @MainActor @Sendable (Preferences) -> Void
        public let isContentBlockerEnabled: @MainActor @Sendable () async -> Bool
        public let appDidBecomeActive: @Sendable () -> AsyncStream<Void>
        public let reloadContentBlocker: @MainActor @Sendable () async -> Void
        public let showContentBlockerTutorial: @MainActor @Sendable () -> Void

        public init(
            loadPreferences: @MainActor @Sendable @escaping () -> Preferences,
            isAutomationEnabled: @MainActor @Sendable @escaping () -> Bool,
            preferencesChanges: @Sendable @escaping () -> AsyncStream<Void>,
            savePreferences: @MainActor @Sendable @escaping (Preferences) -> Void,
            isContentBlockerEnabled: @MainActor @Sendable @escaping () async -> Bool,
            appDidBecomeActive: @Sendable @escaping () -> AsyncStream<Void>,
            reloadContentBlocker: @MainActor @Sendable @escaping () async -> Void,
            showContentBlockerTutorial: @MainActor @Sendable @escaping () -> Void,
        ) {
            self.loadPreferences = loadPreferences
            self.isAutomationEnabled = isAutomationEnabled
            self.preferencesChanges = preferencesChanges
            self.savePreferences = savePreferences
            self.isContentBlockerEnabled = isContentBlockerEnabled
            self.appDidBecomeActive = appDidBecomeActive
            self.reloadContentBlocker = reloadContentBlocker
            self.showContentBlockerTutorial = showContentBlockerTutorial
        }
    }
}
