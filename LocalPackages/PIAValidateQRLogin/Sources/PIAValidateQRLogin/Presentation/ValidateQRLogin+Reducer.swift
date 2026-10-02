//
//  ValidateQRLogin+Reducer.swift
//  PIAValidateQRLogin
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

extension ValidateQRLogin {

    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                guard state.phase == .idle else { return nil }
                state.phase = .confirming
                return nil

            case .confirmTapped:
                guard state.phase == .confirming else { return nil }
                state.phase = .validating
                return .task { [dependencies] in
                    .validated(await dependencies.validate())
                }

            case .cancelTapped:
                guard state.phase == .confirming else { return nil }
                return finish(&state, .dismiss)

            case .validated(.success):
                return finish(&state, .dismiss)

            case .validated(.failure):
                state.phase = .failed
                return nil

            case .errorAcknowledged:
                guard state.phase == .failed else { return nil }
                return finish(&state, .dismiss)
            }
        }

        // Each scanned token gets one attempt, so every way out discards it.
        private func finish(_ state: inout State, _ output: Output) -> Effect<Action> {
            state.phase = .finished
            return .fireAndForget { [dependencies] in
                dependencies.discardQRToken()
                dependencies.emit(output)
            }
        }
    }
}
