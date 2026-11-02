//
//  ProtocolSettings+Reducer.swift
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

extension ProtocolSettings {
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

            case .vpnProtocolSelected(let vpnProtocol):
                guard state.preferences.vpnProtocol != vpnProtocol else { return nil }
                state.preferences.vpnProtocol = vpnProtocol
                return update { $0.setVPNProtocol(vpnProtocol) }

            case .transportSelected(let transport):
                guard state.preferences.transport != transport else { return nil }
                state.preferences.transport = transport
                state.preferences.remotePort = ProtocolSettings.automaticPort
                return update { $0.setTransport(transport) }

            case .remotePortSelected(let port):
                guard state.preferences.remotePort != port else { return nil }
                state.preferences.remotePort = port
                return update { $0.setRemotePort(port) }

            case .cipherSelected(let cipher):
                guard state.preferences.cipher != cipher else { return nil }
                state.preferences.cipher = cipher
                return update { $0.setCipher(cipher) }

            case .smallPacketsToggled(let isOn):
                guard state.preferences.usesSmallPackets != isOn else { return nil }
                state.preferences.usesSmallPackets = isOn
                return update { $0.setUsesSmallPackets(isOn) }

            case .preferencesLoaded(let preferences):
                state.preferences = preferences
                return nil
            }
        }

        private func update(_ work: @escaping @MainActor (Dependencies) -> Void) -> Effect<Action> {
            .task { [dependencies] in
                work(dependencies)
                return .preferencesLoaded(dependencies.loadPreferences())
            }
        }
    }
}
