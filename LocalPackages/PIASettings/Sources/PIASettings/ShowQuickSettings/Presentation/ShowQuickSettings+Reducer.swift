//
//  ShowQuickSettings+Reducer.swift
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

extension ShowQuickSettings {
    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .optionToggled(let option, let isVisible):
                guard state.visibleOptions.contains(option) != isVisible else { return nil }
                if isVisible {
                    state.visibleOptions.insert(option)
                } else {
                    // The Quick Settings tile must keep at least one option
                    guard state.visibleOptions.count > 1 else {
                        state.isMinimumVisibleAlertPresented = true
                        return nil
                    }
                    state.visibleOptions.remove(option)
                }
                let visibleOptions = state.visibleOptions
                return .fireAndForget { [dependencies] in dependencies.saveVisibleOptions(visibleOptions) }

            case .minimumVisibleAlertDismissed:
                state.isMinimumVisibleAlertPresented = false
                return nil
            }
        }
    }
}
