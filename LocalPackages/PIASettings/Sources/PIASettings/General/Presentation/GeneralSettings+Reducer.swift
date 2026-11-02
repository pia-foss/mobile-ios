//
//  GeneralSettings+Reducer.swift
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

import CoreArchitecture

extension GeneralSettings {
    struct Reducer: Sendable {
        private enum EffectID: Hashable {
            case preferencesChanges
        }

        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                return .stream(id: EffectID.preferencesChanges) { [dependencies] send in
                    for await _ in dependencies.preferencesChanges() {
                        send(.preferencesLoaded(dependencies.loadPreferences()))
                    }
                }

            case .serviceMessagesToggled(let isOn):
                guard state.preferences.showsServiceMessages != isOn else { return nil }
                state.preferences.showsServiceMessages = isOn
                return .fireAndForget { [dependencies] in dependencies.setShowsServiceMessages(isOn) }

            case .geoRegionsToggled(let isOn):
                guard state.preferences.showsGeoRegions != isOn else { return nil }
                state.preferences.showsGeoRegions = isOn
                return .fireAndForget { [dependencies] in dependencies.setShowsGeoRegions(isOn) }

            case .connectSiriShortcutTapped:
                return .fireAndForget { [dependencies] in dependencies.connectSiriShortcut() }

            case .disconnectSiriShortcutTapped:
                return .fireAndForget { [dependencies] in dependencies.disconnectSiriShortcut() }

            case .resetTapped:
                state.isResetConfirmationPresented = true
                return nil

            case .resetConfirmationDismissed:
                state.isResetConfirmationPresented = false
                return nil

            case .resetConfirmed:
                state.isResetConfirmationPresented = false
                return .task { [dependencies] in
                    dependencies.resetToDefaults()
                    return .preferencesLoaded(dependencies.loadPreferences())
                }

            case .preferencesLoaded(let preferences):
                state.preferences = preferences
                return nil
            }
        }
    }
}
