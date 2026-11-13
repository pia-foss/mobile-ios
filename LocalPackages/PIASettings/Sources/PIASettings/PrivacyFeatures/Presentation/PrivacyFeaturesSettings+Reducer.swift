//
//  PrivacyFeaturesSettings+Reducer.swift
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

extension PrivacyFeaturesSettings {
    struct Reducer: Sendable {
        private enum EffectID: Hashable {
            case preferencesChanges
            case contentBlockerState
            case refreshBlockList
        }

        // Keeps the spinner visible when the reload returns instantly
        private static let minimumRefreshNanoseconds: UInt64 = 250_000_000

        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                return .merge(
                    .stream(id: EffectID.preferencesChanges) { [dependencies] send in
                        for await _ in dependencies.preferencesChanges() {
                            send(.preferencesLoaded(dependencies.loadPreferences()))
                        }
                    },
                    .stream(id: EffectID.contentBlockerState) { [dependencies] send in
                        send(.contentBlockerStateLoaded(await dependencies.isContentBlockerEnabled()))
                        for await _ in dependencies.appDidBecomeActive() {
                            send(.contentBlockerStateLoaded(await dependencies.isContentBlockerEnabled()))
                        }
                    }
                )

            case .preferencesLoaded(let preferences):
                state.preferences = preferences
                return nil

            case .killSwitchToggled(let isOn):
                guard state.preferences.killSwitch != isOn else { return nil }
                state.isKillSwitchWarningPresented = !isOn && state.isAutomationEnabled
                return setKillSwitch(isOn, in: &state)

            case .killSwitchWarningConfirmed:
                state.isKillSwitchWarningPresented = false
                return setKillSwitch(true, in: &state)

            case .killSwitchWarningDismissed:
                state.isKillSwitchWarningPresented = false
                return nil

            case .reconnectNotificationsToggled(let isOn):
                guard state.preferences.reconnectNotifications != isOn else { return nil }
                state.preferences.reconnectNotifications = isOn
                return save(state.preferences)

            case .contentBlockerToggled:
                return .fireAndForget { [dependencies] in dependencies.showContentBlockerTutorial() }

            case .contentBlockerStateLoaded(let isEnabled):
                state.isContentBlockerEnabled = isEnabled
                return nil

            case .refreshBlockListTapped:
                guard !state.isRefreshingBlockList else { return nil }
                state.isRefreshingBlockList = true
                return .task(id: EffectID.refreshBlockList) { [dependencies] in
                    async let minimumDuration: Void? = try? Task.sleep(nanoseconds: Self.minimumRefreshNanoseconds)
                    await dependencies.reloadContentBlocker()
                    _ = await minimumDuration
                    return .blockListRefreshed
                }

            case .blockListRefreshed:
                state.isRefreshingBlockList = false
                return nil
            }
        }

        // Reconnect notifications follow the kill switch
        private func setKillSwitch(_ isOn: Bool, in state: inout State) -> Effect<Action> {
            state.preferences.killSwitch = isOn
            state.preferences.reconnectNotifications = isOn
            return save(state.preferences)
        }

        private func save(_ preferences: Preferences) -> Effect<Action> {
            .fireAndForget { [dependencies] in dependencies.savePreferences(preferences) }
        }
    }
}
