//
//  Login+Reducer.swift
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

extension Login {
    struct Reducer: Sendable {
        private enum EffectID: Hashable {
            case magicLinkTokens
        }

        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                return .stream(id: EffectID.magicLinkTokens) { [dependencies] send in
                    for await token in dependencies.magicLinkTokens() {
                        send(.magicLinkTokenReceived(token))
                    }
                }

            case .usernameChanged(let username):
                guard username != state.username else { return nil }
                state.username = username
                state.invalidFields.remove(.username)
                return nil

            case .passwordChanged(let password):
                guard password != state.password else { return nil }
                state.password = password
                state.invalidFields.remove(.password)
                return nil

            case .loginTapped:
                if let throttled = throttledError(for: .credentials, in: state) { return throttled }
                guard state.inFlight == nil else { return nil }

                let username = state.username.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = state.password.trimmingCharacters(in: .whitespacesAndNewlines)
                var invalidFields: Set<Field> = []
                if username.isEmpty {
                    invalidFields.insert(.username)
                }
                if password.isEmpty {
                    invalidFields.insert(.password)
                }
                state.invalidFields = invalidFields
                guard invalidFields.isEmpty else {
                    return emit(.showError(message: L10n.Welcome.Login.Error.validation, duration: nil))
                }

                state.inFlight = .credentials
                let credentials = Credentials(username: username, password: password)
                return .task { [dependencies] in
                    .loginResponse(.credentials, await dependencies.login(credentials))
                }

            case .receiptLoginTapped:
                if let throttled = throttledError(for: .receipt, in: state) { return throttled }
                guard state.inFlight == nil else { return nil }
                state.inFlight = .receipt
                return .task { [dependencies] in
                    .loginResponse(.receipt, await dependencies.loginWithReceipt())
                }

            case .restorePurchaseTapped:
                guard state.inFlight == nil else { return nil }
                return emit(.restorePurchaseRequested)

            case .magicLinkTapped:
                if let throttled = throttledError(for: .magicLink, in: state) { return throttled }
                guard state.inFlight == nil else { return nil }
                state.magicLinkEmail = ""
                state.isMagicLinkPromptPresented = true
                return nil

            case .magicLinkEmailChanged(let email):
                state.magicLinkEmail = email
                return nil

            case .magicLinkPromptDismissed:
                state.isMagicLinkPromptPresented = false
                return nil

            case .magicLinkSendTapped:
                state.isMagicLinkPromptPresented = false
                guard state.inFlight == nil else { return nil }

                let email = state.magicLinkEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                do {
                    try Validator.validate(email: email)
                } catch {
                    return emit(.showError(message: error.message, duration: nil))
                }

                state.inFlight = .magicLink
                return .task { [dependencies] in
                    .magicLinkResponse(await dependencies.requestMagicLink(email))
                }

            case .magicLinkTokenReceived(let token):
                guard state.inFlight == nil else { return nil }
                state.inFlight = .magicLinkToken
                return .task { [dependencies] in
                    .loginResponse(.magicLinkToken, await dependencies.loginWithMagicLinkToken(token))
                }

            case .loginResponse(let method, .success(let user)):
                guard state.inFlight == method else { return nil }
                state.inFlight = nil
                return emit(.didLogin(user))

            case .loginResponse(let method, .failure(let error)):
                guard state.inFlight == method else { return nil }
                state.inFlight = nil
                return fail(method, with: error, state: &state)

            case .magicLinkResponse(.success):
                guard state.inFlight == .magicLink else { return nil }
                state.inFlight = nil
                return emit(.showMessage(L10n.Welcome.Login.Magic.Link.response))

            case .magicLinkResponse(.failure(let error)):
                guard state.inFlight == .magicLink else { return nil }
                state.inFlight = nil
                return fail(.magicLink, with: error, state: &state)

            case .alertDismissed:
                state.isBadReceiptAlertPresented = false
                return nil
            }
        }

        // MARK: - Helpers

        private func emit(_ output: Output) -> Effect<Action> {
            .fireAndForget { [dependencies] in dependencies.emit(output) }
        }

        /// The backend rejects retries until its throttle window passes, so they are refused here
        /// without a round trip, with the time left.
        private func throttledError(for method: Method, in state: State) -> Effect<Action>? {
            guard let retryAfter = state.retryAfter[method] else { return nil }
            let remaining = retryAfter.timeIntervalSince(dependencies.now())
            guard remaining > 0 else { return nil }
            return emit(
                .showError(
                    message: L10n.Welcome.Login.Error.throttled("\(Int(remaining.rounded(.up)))"),
                    duration: remaining
                )
            )
        }

        private func fail(_ method: Method, with error: LoginError, state: inout State) -> Effect<Action>? {
            // A link token can only fail by being stale or unreachable; the old screen said so.
            if method == .magicLinkToken {
                return emit(.showError(message: L10n.Welcome.Purchase.Error.Connectivity.title, duration: nil))
            }

            switch error {
            case .expired:
                return emit(.accountExpired)

            case .badReceipt:
                state.isBadReceiptAlertPresented = true
                return nil

            default:
                if case .throttled(let retryAfter) = error {
                    state.retryAfter[method] = dependencies.now().addingTimeInterval(TimeInterval(retryAfter))
                }
                return emit(.showError(message: error.message, duration: nil))
            }
        }
    }
}
