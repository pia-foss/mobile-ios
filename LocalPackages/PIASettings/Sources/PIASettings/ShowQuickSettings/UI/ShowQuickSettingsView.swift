//
//  ShowQuickSettingsView.swift
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

import PIAAssetsMobile
import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

public struct ShowQuickSettingsView: View, ViewWithTitle {
    @StateObject private var store: ShowQuickSettingsStore

    public var navigationTitle: String { L10n.Tiles.Quicksettings.title }

    public init(dependencies: ShowQuickSettings.Dependencies) {
        _store = StateObject(
            wrappedValue: ShowQuickSettingsStore(
                initialState: .init(visibleOptions: dependencies.loadVisibleOptions()),
                dependencies: dependencies
            )
        )
    }

    public var body: some View {
        SettingsList {
            ForEach(ShowQuickSettings.Option.allCases, id: \.self) { option in
                SettingsToggleRow(
                    title: option.title,
                    icon: option.icon,
                    isOn: store.binding(\.[isVisible: option]) { .optionToggled(option, isVisible: $0) }
                )
            }
        }
        .alert(
            L10n.Tiles.Quicksettings.title,
            isPresented: store.binding(\.isMinimumVisibleAlertPresented) { _ in .minimumVisibleAlertDismissed },
            actions: {
                Button(L10n.Global.ok) {}
                    .keyboardShortcut(.defaultAction)
            },
            message: {
                Text(L10n.Tiles.Quicksettings.Min.Elements.message)
            }
        )
    }
}

extension ShowQuickSettings.State {
    fileprivate subscript(isVisible option: ShowQuickSettings.Option) -> Bool {
        visibleOptions.contains(option)
    }
}

extension ShowQuickSettings.Option {
    fileprivate var title: String {
        switch self {
        case .killSwitch: L10n.Settings.ApplicationSettings.KillSwitch.title
        case .automation: L10n.Tiles.Quicksetting.Automation.title
        case .privateBrowser: L10n.Tiles.Quicksetting.Private.Browser.title
        }
    }

    fileprivate var icon: Image {
        switch self {
        case .killSwitch: Asset.Piax.Global.killswitchInactive.swiftUIImage
        case .automation: Asset.Piax.Global.nmtInactive.swiftUIImage
        case .privateBrowser: Asset.Piax.Global.browserInactive.swiftUIImage
        }
    }
}

#Preview {
    ShowQuickSettingsView(
        dependencies: .init(
            loadVisibleOptions: { [.killSwitch, .privateBrowser] },
            saveVisibleOptions: { _ in }
        )
    )
}
