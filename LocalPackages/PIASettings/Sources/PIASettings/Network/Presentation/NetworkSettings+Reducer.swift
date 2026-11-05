//
//  NetworkSettings+Reducer.swift
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

extension NetworkSettings {
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

            case .dnsSelected(.custom) where !state.hasCustomDNS:
                state.isCustomDNSWarningPresented = true
                return nil

            case .dnsSelected(let dns):
                guard state.preferences.dns != dns else { return nil }
                state.preferences.dns = dns
                return .task { [dependencies] in
                    dependencies.setDNS(dns)
                    return .preferencesLoaded(dependencies.loadPreferences())
                }

            case .customDNSTapped:
                guard state.hasCustomDNS else {
                    state.isCustomDNSWarningPresented = true
                    return nil
                }
                return .fireAndForget { [dependencies] in dependencies.showCustomDNS() }

            case .customDNSWarningConfirmed:
                state.isCustomDNSWarningPresented = false
                return .fireAndForget { [dependencies] in dependencies.showCustomDNS() }

            case .customDNSWarningDismissed:
                state.isCustomDNSWarningPresented = false
                return nil

            case .preferencesLoaded(let preferences):
                state.preferences = preferences
                return nil
            }
        }
    }
}
