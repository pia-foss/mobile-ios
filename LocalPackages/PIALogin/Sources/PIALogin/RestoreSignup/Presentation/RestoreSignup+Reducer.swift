//
//  RestoreSignup+Reducer.swift
//  PIALogin
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
import PIALibrary
import PIALocalizations

extension RestoreSignup {
    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .emailChanged(let email):
                // Focusing the field writes the same text back; that is not an edit.
                guard email != state.email else { return nil }
                state.email = email
                state.isEmailInvalid = false
                return nil

            case .submitTapped:
                guard !state.isRestoring else { return nil }
                let email = state.email.trimmingCharacters(in: .whitespacesAndNewlines)
                do {
                    try Validator.validate(email: email)
                } catch {
                    state.isEmailInvalid = true
                    return emit(.showError(message: error.message))
                }

                state.isEmailInvalid = false
                state.isRestoring = true
                return .task { [dependencies] in
                    .restoreResponse(await dependencies.restorePurchases())
                }

            case .restoreResponse(.success):
                guard state.isRestoring else { return nil }
                state.isRestoring = false
                let email = state.email.trimmingCharacters(in: .whitespacesAndNewlines)
                return emit(.didRestore(email: email))

            case .restoreResponse(.failure(let error)):
                guard state.isRestoring else { return nil }
                state.isRestoring = false
                return emit(.showError(message: error.message))
            }
        }

        private func emit(_ output: Output) -> Effect<Action> {
            .fireAndForget { [dependencies] in dependencies.emit(output) }
        }
    }
}

extension RestoreSignupError {
    var message: String {
        switch self {
        case .nothingToRestore: L10n.Account.Restore.Failure.message
        case .failed(let message): message
        }
    }
}
