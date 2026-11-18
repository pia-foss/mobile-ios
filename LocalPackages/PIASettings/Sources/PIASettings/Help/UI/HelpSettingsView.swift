//
//  HelpSettingsView.swift
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

public struct HelpSettingsView: View, ViewWithTitle {
    @StateObject private var store: HelpSettingsStore

    public var navigationTitle: String { L10n.Settings.Section.help }

    public init(initialState: HelpSettings.State, dependencies: HelpSettings.Dependencies) {
        _store = StateObject(wrappedValue: HelpSettingsStore(initialState: initialState, dependencies: dependencies))
    }

    public var body: some View {
        SettingsList {
            SettingsNavigationRow(title: L10n.Settings.ApplicationInformation.Debug.title) {
                store.send(.sendDebugReportTapped)
            }

            SettingsToggleRow(
                title: L10n.Settings.ApplicationInformation.DebugLogging.title,
                description: L10n.Settings.Log.information,
                isOn: store.binding(\.preferences.debugLogging) { .debugLoggingToggled($0) }
            )
            .disabled(!store.state.isDebugLoggingEditable)

            SettingsToggleRow(
                title: L10n.Settings.Service.Quality.Share.title,
                description: L10n.Settings.Service.Quality.Share.description,
                link: SettingsLink(title: L10n.Settings.Service.Quality.Share.findoutmore) {
                    store.send(.serviceQualityInformationTapped)
                },
                isOn: store.binding(\.preferences.sharesServiceQualityData) { .shareServiceQualityDataToggled($0) }
            )

            if store.state.preferences.sharesServiceQualityData {
                SettingsNavigationRow(title: L10n.Settings.Service.Quality.Show.title) {
                    store.send(.serviceQualityEventsTapped)
                }
            }

            SettingsGap()

            SettingsNavigationRow(title: L10n.Settings.Cards.History.title) {
                store.send(.latestNewsTapped)
            }

            SettingsGap()

            SettingsRow(store.state.version) {
                EmptyView()
            }
        }
    }
}
