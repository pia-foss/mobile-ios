//
//  DedicatedIP+Reducer.swift
//  PIADedicatedIP
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
import Foundation
import PIALocalizations

extension DedicatedIP {

    public struct Reducer: Sendable {
        let dependencies: Dependencies

        public init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }

        public func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .tokenChanged(let token):
                state.token = token
                return nil

            case .activateTapped:
                return activate(&state)

            case .activated(.success(let info)):
                state.isLoading = false
                state.token = ""
                state.dip = info
                return .merge(emit(.didChange), note(.success, L10n.Dedicated.Ip.Message.Valid.token))

            case .activated(.failure(let failure)):
                state.isLoading = false
                return activationFailed(&state, failure)

            case .removeConfirmed:
                state.isLoading = true
                return .task {
                    await dependencies.remove()
                    return .removed(dependencies.getDedicatedIP())
                }

            case .removed(let info):
                state.isLoading = false
                state.dip = info
                return emit(.didChange)
            }
        }

        private func activate(_ state: inout State) -> Effect<Action>? {
            if let retryUntil = state.retryUntil {
                let remaining = retryUntil.timeIntervalSinceNow
                if remaining > 0 {
                    return retryNote(remaining)
                }
                state.retryUntil = nil
            }

            guard !state.token.isEmpty else {
                return note(.sticky, L10n.Dedicated.Ip.Message.Incorrect.token)
            }

            state.isLoading = true
            let token = state.token
            return .task { .activated(await dependencies.activate(token)) }
        }

        private func activationFailed(_ state: inout State, _ failure: Failure) -> Effect<Action> {
            switch failure {
            case .alreadyHasOne:
                return note(.sticky, L10n.Dedicated.Ip.Message.Error.alreadyHasOne)
            case .expired:
                return note(.sticky, L10n.Dedicated.Ip.Message.Expired.token)
            case .invalid:
                return note(.sticky, L10n.Dedicated.Ip.Message.Invalid.token)
            case .unauthorized:
                return emit(.unauthorized)
            case .throttled(let retryAfter):
                state.retryUntil = Date().addingTimeInterval(retryAfter)
                return retryNote(retryAfter)
            }
        }

        private func retryNote(_ seconds: TimeInterval) -> Effect<Action> {
            note(.timed(seconds), L10n.Dedicated.Ip.Message.Error.retryafter("\(Int(seconds))"))
        }

        private func note(_ kind: Note.Kind, _ message: String) -> Effect<Action> {
            emit(.showNote(Note(kind: kind, message: message)))
        }

        private func emit(_ output: Output) -> Effect<Action> {
            .fireAndForget { dependencies.emit(output) }
        }
    }
}
