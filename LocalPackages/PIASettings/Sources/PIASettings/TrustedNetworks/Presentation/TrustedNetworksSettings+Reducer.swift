//
//  TrustedNetworksSettings+Reducer.swift
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

extension TrustedNetworksSettings {
    struct Reducer: Sendable {
        private enum EffectID: Hashable {
            case appDidBecomeActive
        }

        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                return .stream(id: EffectID.appDidBecomeActive) { [dependencies] send in
                    for await _ in dependencies.appDidBecomeActive() {
                        send(.rulesLoaded(dependencies.loadRules()))
                        send(.availableNetworksLoaded(dependencies.loadAvailableNetworks()))
                    }
                }

            case .addNetworkAppeared:
                return .task { [dependencies] in .availableNetworksLoaded(dependencies.loadAvailableNetworks()) }

            case .rulesLoaded(let rules):
                state.rules = rules
                return nil

            case .availableNetworksLoaded(let networks):
                state.availableNetworks = networks
                return nil

            case .behaviorSelected(let network, let behavior):
                guard
                    let index = state.rules.firstIndex(where: { $0.network == network }),
                    state.rules[index].behavior != behavior
                else {
                    return nil
                }
                state.rules[index].behavior = behavior
                return .fireAndForget { [dependencies] in dependencies.saveRule(network, behavior) }

            case .removeTapped(let ssid):
                let network = Network.custom(ssid: ssid)
                state.rules.removeAll { $0.network == network }
                return .fireAndForget { [dependencies] in dependencies.saveRule(network, nil) }

            case .addRuleTapped:
                return .fireAndForget { [dependencies] in dependencies.showAddNetwork() }

            case .customNetworkSelected(let ssid, let behavior):
                state.availableNetworks.removeAll { $0 == ssid }
                return .task { [dependencies] in
                    dependencies.saveRule(.custom(ssid: ssid), behavior)
                    dependencies.didAddNetwork()
                    return .rulesLoaded(dependencies.loadRules())
                }

            case .killSwitchWarningConfirmed:
                state.isKillSwitchWarningPresented = false
                return .fireAndForget { [dependencies] in dependencies.enableKillSwitch() }

            case .killSwitchWarningDismissed:
                state.isKillSwitchWarningPresented = false
                return nil
            }
        }
    }
}
