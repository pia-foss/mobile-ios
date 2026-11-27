//
//  AutomationSettingsView.swift
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

public struct AutomationSettingsView: View, ViewWithTitle {
    @StateObject private var store: AutomationSettingsStore

    public var navigationTitle: String { L10n.Settings.Section.automation }

    public init(dependencies: AutomationSettings.Dependencies) {
        _store = StateObject(
            wrappedValue: AutomationSettingsStore(
                initialState: .init(
                    isAutomationEnabled: dependencies.isAutomationEnabled(),
                    isKillSwitchEnabled: dependencies.isKillSwitchEnabled()
                ),
                dependencies: dependencies
            )
        )
    }

    public var body: some View {
        SettingsList {
            SettingsToggleRow(
                title: L10n.Network.Management.Tool.Enable.automation,
                description: L10n.Settings.Hotspothelper.description,
                isOn: store.binding(\.isAutomationEnabled) { .automationToggled($0) }
            )

            if store.state.isAutomationEnabled {
                SettingsNavigationRow(title: L10n.Network.Management.Tool.title) {
                    store.send(.manageAutomationTapped)
                }
            }
        }
        .task { store.send(.onAppear) }
        .alert(
            L10n.Tiles.Quicksetting.Automation.title,
            isPresented: store.binding(\.isKillSwitchRequiredAlertPresented) { _ in .killSwitchRequiredDismissed },
            actions: {
                Button(L10n.Global.enable) {
                    store.send(.killSwitchRequiredConfirmed)
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
    AutomationSettingsView(
        dependencies: .init(
            isAutomationEnabled: { true },
            preferencesChanges: { AsyncStream { $0.finish() } },
            setAutomationEnabled: { _ in },
            isKillSwitchEnabled: { true },
            enableKillSwitch: {},
            showManageAutomation: {},
        )
    )
}
