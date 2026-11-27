//
//  AutomationSettings.swift
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

public enum AutomationSettings {}

extension AutomationSettings {
    public struct State: Equatable, Sendable {
        public var isAutomationEnabled: Bool
        /// Automation only works with the kill switch on, so turning it on while the kill switch is off asks first.
        public var isKillSwitchRequiredAlertPresented = false
        public var isKillSwitchEnabled: Bool

        public init(isAutomationEnabled: Bool, isKillSwitchEnabled: Bool) {
            self.isAutomationEnabled = isAutomationEnabled
            self.isKillSwitchEnabled = isKillSwitchEnabled
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case automationToggled(Bool)
        case killSwitchRequiredConfirmed
        case killSwitchRequiredDismissed
        case manageAutomationTapped
        case preferencesLoaded(isAutomationEnabled: Bool, isKillSwitchEnabled: Bool)
    }

    public struct Dependencies: Sendable {
        public let isAutomationEnabled: @MainActor @Sendable () -> Bool
        public let preferencesChanges: @Sendable () -> AsyncStream<Void>
        public let setAutomationEnabled: @MainActor @Sendable (Bool) -> Void
        public let isKillSwitchEnabled: @MainActor @Sendable () -> Bool
        public let enableKillSwitch: @MainActor @Sendable () -> Void
        public let showManageAutomation: @MainActor @Sendable () -> Void

        public init(
            isAutomationEnabled: @MainActor @Sendable @escaping () -> Bool,
            preferencesChanges: @Sendable @escaping () -> AsyncStream<Void>,
            setAutomationEnabled: @MainActor @Sendable @escaping (Bool) -> Void,
            isKillSwitchEnabled: @MainActor @Sendable @escaping () -> Bool,
            enableKillSwitch: @MainActor @Sendable @escaping () -> Void,
            showManageAutomation: @MainActor @Sendable @escaping () -> Void,
        ) {
            self.isAutomationEnabled = isAutomationEnabled
            self.preferencesChanges = preferencesChanges
            self.setAutomationEnabled = setAutomationEnabled
            self.isKillSwitchEnabled = isKillSwitchEnabled
            self.enableKillSwitch = enableKillSwitch
            self.showManageAutomation = showManageAutomation
        }
    }
}
