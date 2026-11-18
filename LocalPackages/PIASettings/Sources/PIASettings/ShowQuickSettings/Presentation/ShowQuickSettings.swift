//
//  ShowQuickSettings.swift
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

public enum ShowQuickSettings {}

extension ShowQuickSettings {
    public enum Option: CaseIterable, Hashable, Sendable {
        case killSwitch
        case automation
        case privateBrowser
    }

    public struct State: Equatable, Sendable {
        public var visibleOptions: Set<Option>
        public var isMinimumVisibleAlertPresented = false

        public init(visibleOptions: Set<Option>) {
            self.visibleOptions = visibleOptions
        }
    }

    public enum Action: Equatable, Sendable {
        case optionToggled(Option, isVisible: Bool)
        case minimumVisibleAlertDismissed
    }

    public struct Dependencies: Sendable {
        public let loadVisibleOptions: @MainActor @Sendable () -> Set<Option>
        public let saveVisibleOptions: @MainActor @Sendable (Set<Option>) -> Void

        public init(
            loadVisibleOptions: @MainActor @Sendable @escaping () -> Set<Option>,
            saveVisibleOptions: @MainActor @Sendable @escaping (Set<Option>) -> Void
        ) {
            self.loadVisibleOptions = loadVisibleOptions
            self.saveVisibleOptions = saveVisibleOptions
        }
    }
}
