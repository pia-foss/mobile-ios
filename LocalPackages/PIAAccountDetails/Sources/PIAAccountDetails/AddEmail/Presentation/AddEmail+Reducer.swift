//
//  AddEmail+Reducer.swift
//  PIAAccountDetails
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

extension AddEmail {

    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .emailChanged(let email):
                state.email = email
                state.emailError = nil
                return nil

            case .submitTapped:
                return submit(&state)

            case .consentGiven:
                state.hasConsented = true
                state.alert = nil
                return submit(&state)

            case .alertDismissed:
                state.alert = nil
                return nil

            case .appleIDAuthorized(let email):
                guard state.step == .form, !state.isSubmitting else { return nil }
                return .task { [dependencies] in
                    if let email, !email.isEmpty {
                        dependencies.storeAppleIDEmail(email)
                        return .appleIDEmailResolved(email)
                    }
                    // Apple only shares the email the first time, so fall back to the one it shared then.
                    return .appleIDEmailResolved(dependencies.storedAppleIDEmail())
                }

            case .appleIDEmailResolved(let email):
                state.email = email ?? ""
                state.emailError = nil
                return submit(&state)

            case .updateSucceeded(let email, let credentials):
                state.isSubmitting = false
                state.step = .done(email: email, credentials: credentials)
                return nil

            case .updateFailed:
                state.isSubmitting = false
                state.email = ""
                state.alert = .updateFailed
                return nil

            case .closeTapped:
                return .fireAndForget { [dependencies] in
                    dependencies.clearTemporaryPassword()
                    dependencies.emit(.finished)
                }

            case .logoutTapped:
                guard !state.isLoggingOut, !state.isSubmitting else { return nil }
                state.isLoggingOut = true
                return .task { [dependencies] in
                    .logoutFinished(succeeded: await dependencies.logout())
                }

            case .logoutFinished(let succeeded):
                state.isLoggingOut = false
                guard succeeded else { return nil }
                return .fireAndForget { [dependencies] in dependencies.emit(.loggedOut) }
            }
        }

        /// Validates the email, asks for consent the first time, then sends it.
        private func submit(_ state: inout State) -> Effect<Action>? {
            guard state.step == .form, !state.isSubmitting, !state.isLoggingOut else { return nil }

            let email = state.email.trimmingCharacters(in: .whitespacesAndNewlines)
            do {
                try Validator.validate(email: email)
            } catch {
                state.emailError = error
                return nil
            }

            guard state.hasConsented else {
                state.alert = .consent
                return nil
            }

            state.isSubmitting = true
            return .task { [dependencies] in
                guard let credentials = await dependencies.updateEmail(email) else { return .updateFailed }
                return .updateSucceeded(email: email, credentials: credentials)
            }
        }
    }
}
