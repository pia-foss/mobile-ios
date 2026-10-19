//
//  GeneralSettingsView.swift
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

import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

public struct GeneralSettingsView: View, ViewWithTitle {
    @StateObject private var store: GeneralSettingsStore

    public var navigationTitle: String { L10n.Settings.Section.general }

    public init(dependencies: GeneralSettings.Dependencies) {
        _store = StateObject(
            wrappedValue: GeneralSettingsStore(
                initialState: .init(preferences: dependencies.loadPreferences()),
                dependencies: dependencies
            )
        )
    }

    public var body: some View {
        PIASettingsList {
            PIASettingsNavigationRow(L10n.Siri.Shortcuts.Connect.Row.title) {
                store.send(.connectSiriShortcutTapped)
            }
            PIASettingsNavigationRow(L10n.Siri.Shortcuts.Disconnect.Row.title) {
                store.send(.disconnectSiriShortcutTapped)
            }
            PIASettingsToggleRow(
                L10n.Inapp.Messages.Toggle.title,
                isOn: store.binding(\.preferences.showsServiceMessages) { .serviceMessagesToggled($0) }
            )
            PIASettingsToggleRow(
                L10n.Settings.Geo.Servers.description,
                isOn: store.binding(\.preferences.showsGeoRegions) { .geoRegionsToggled($0) }
            )
            PIASettingsNavigationRow(
                L10n.Settings.Reset.Defaults.title,
                description: L10n.Settings.Reset.footer
            ) {
                store.send(.resetTapped)
            }
        }
        .task { store.send(.onAppear) }
        .alert(
            L10n.Settings.Reset.Defaults.Confirm.title,
            isPresented: store.binding(\.isResetConfirmationPresented) { _ in .resetConfirmationDismissed },
            actions: {
                Button(L10n.Settings.Reset.Defaults.Confirm.button, role: .destructive) {
                    store.send(.resetConfirmed)
                }
                Button(L10n.Global.cancel, role: .cancel) {}
            },
            message: {
                Text(L10n.Settings.Reset.Defaults.Confirm.message)
            }
        )
    }
}

#Preview {
    GeneralSettingsView(
        dependencies: .init(
            loadPreferences: { .init(showsServiceMessages: true, showsGeoRegions: false) },
            preferencesChanges: { AsyncStream { $0.finish() } },
            setShowsServiceMessages: { _ in },
            setShowsGeoRegions: { _ in },
            resetToDefaults: {},
            connectSiriShortcut: {},
            disconnectSiriShortcut: {},
        )
    )
}
