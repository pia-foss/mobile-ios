//
//  ShowQuickSettingsCoordinator.swift
//  PIA VPN
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

import PIALibrary
import PIASettings

final class ShowQuickSettingsCoordinator: ModalCoordinator<ShowQuickSettingsView> {
    override func buildContent() -> ShowQuickSettingsView {
        ShowQuickSettingsView(
            dependencies: .init(
                loadVisibleOptions: { Self.visibleOptions() },
                saveVisibleOptions: { Self.save($0) }
            )
        )
    }

    private static func visibleOptions() -> Set<ShowQuickSettings.Option> {
        Set(ShowQuickSettings.Option.allCases.filter { AppPreferences.shared[keyPath: $0.preference] })
    }

    private static func save(_ options: Set<ShowQuickSettings.Option>) {
        for option in ShowQuickSettings.Option.allCases {
            AppPreferences.shared[keyPath: option.preference] = options.contains(option)
        }
        Macros.postNotification(.PIATilesDidChange)
    }
}

extension ShowQuickSettings.Option {
    fileprivate var preference: ReferenceWritableKeyPath<AppPreferences, Bool> {
        switch self {
        case .killSwitch: \.quickSettingKillswitchVisible
        case .automation: \.quickSettingNetworkToolVisible
        case .privateBrowser: \.quickSettingPrivateBrowserVisible
        }
    }
}
