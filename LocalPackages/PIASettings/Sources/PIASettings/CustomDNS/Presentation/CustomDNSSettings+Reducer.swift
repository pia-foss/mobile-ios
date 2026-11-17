//
//  CustomDNSSettings+Reducer.swift
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

extension CustomDNSSettings {
    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .primaryChanged(let value):
                state.primary = value
                return nil

            case .secondaryChanged(let value):
                state.secondary = value
                return nil

            case .updateTapped:
                if let error = state.validationError {
                    state.alert = error
                    return nil
                }
                let servers = state.servers
                return .fireAndForget { [dependencies] in
                    dependencies.save(servers)
                    dependencies.dismiss()
                }

            case .clearTapped:
                state.alert = .clearConfirmation
                return nil

            case .clearConfirmed:
                state.alert = nil
                return .fireAndForget { [dependencies] in
                    dependencies.clear()
                    dependencies.dismiss()
                }

            case .alertDismissed:
                state.alert = nil
                return nil
            }
        }
    }
}
