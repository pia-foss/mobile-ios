//
//  AutomationSettings+Reducer.swift
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

extension AutomationSettings {
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
                        send(
                            .preferencesLoaded(
                                isAutomationEnabled: dependencies.isAutomationEnabled(),
                                isKillSwitchEnabled: dependencies.isKillSwitchEnabled()
                            )
                        )
                    }
                }

            case .automationToggled(let isOn):
                guard state.isAutomationEnabled != isOn else { return nil }
                if isOn && !state.isKillSwitchEnabled {
                    state.isKillSwitchRequiredAlertPresented = true
                    return nil
                }
                state.isAutomationEnabled = isOn
                return .fireAndForget { [dependencies] in dependencies.setAutomationEnabled(isOn) }

            case .killSwitchRequiredConfirmed:
                state.isKillSwitchRequiredAlertPresented = false
                state.isKillSwitchEnabled = true
                state.isAutomationEnabled = true
                return .fireAndForget { [dependencies] in
                    dependencies.enableKillSwitch()
                    dependencies.setAutomationEnabled(true)
                }

            case .killSwitchRequiredDismissed:
                state.isKillSwitchRequiredAlertPresented = false
                return nil

            case .manageAutomationTapped:
                return .fireAndForget { [dependencies] in dependencies.showManageAutomation() }

            case .preferencesLoaded(let isAutomationEnabled, let isKillSwitchEnabled):
                state.isAutomationEnabled = isAutomationEnabled
                state.isKillSwitchEnabled = isKillSwitchEnabled
                return nil
            }
        }
    }
}
