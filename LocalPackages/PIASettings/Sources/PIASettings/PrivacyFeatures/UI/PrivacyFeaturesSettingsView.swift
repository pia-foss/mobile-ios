//
//  PrivacyFeaturesSettingsView.swift
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

public struct PrivacyFeaturesSettingsView: View, ViewWithTitle {
    @StateObject private var store: PrivacyFeaturesSettingsStore

    public var navigationTitle: String { L10n.Settings.Section.privacyFeatures }

    public init(dependencies: PrivacyFeaturesSettings.Dependencies) {
        _store = StateObject(
            wrappedValue: PrivacyFeaturesSettingsStore(
                initialState: .init(
                    preferences: dependencies.loadPreferences(),
                    isAutomationEnabled: dependencies.isAutomationEnabled()
                ),
                dependencies: dependencies
            )
        )
    }

    public var body: some View {
        SettingsList {
            SettingsToggleRow(
                title: L10n.Settings.ApplicationSettings.KillSwitch.title,
                description: L10n.Settings.ApplicationSettings.KillSwitch.footer,
                isOn: store.binding(\.preferences.killSwitch) { .killSwitchToggled($0) }
            )

            if store.state.preferences.killSwitch {
                SettingsToggleRow(
                    title: L10n.Settings.ApplicationSettings.ReconnectNotifications.title,
                    description: L10n.Settings.ApplicationSettings.ReconnectNotifications.footer,
                    isOn: store.binding(\.preferences.reconnectNotifications) { .reconnectNotificationsToggled($0) }
                )
            }

            SettingsGap()

            SettingsToggleRow(
                title: L10n.Settings.ContentBlocker.title,
                description: L10n.Settings.ContentBlocker.footer,
                isOn: store.binding(\.isContentBlockerEnabled) { _ in .contentBlockerToggled }
            )

            SettingsNavigationRow(
                title: L10n.Settings.ContentBlocker.Refresh.title,
                isLoading: store.state.isRefreshingBlockList
            ) {
                store.send(.refreshBlockListTapped)
            }
            .disabled(store.state.isRefreshingBlockList)
        }
        .task { store.send(.onAppear) }
        .alert(
            L10n.Settings.ApplicationSettings.KillSwitch.title,
            isPresented: store.binding(\.isKillSwitchWarningPresented) { _ in .killSwitchWarningDismissed },
            actions: {
                Button(L10n.Global.enable) {
                    store.send(.killSwitchWarningConfirmed)
                }
                .keyboardShortcut(.defaultAction)
                Button(L10n.Global.close, role: .cancel) {}
            },
            message: {
                Text(L10n.Settings.Nmt.Killswitch.disabled)
            }
        )
    }
}

#Preview {
    PrivacyFeaturesSettingsView(
        dependencies: .init(
            loadPreferences: { .init(killSwitch: true, reconnectNotifications: true) },
            isAutomationEnabled: { true },
            preferencesChanges: { AsyncStream { $0.finish() } },
            savePreferences: { _ in },
            isContentBlockerEnabled: { false },
            appDidBecomeActive: { AsyncStream { $0.finish() } },
            reloadContentBlocker: {},
            showContentBlockerTutorial: {},
        )
    )
}
