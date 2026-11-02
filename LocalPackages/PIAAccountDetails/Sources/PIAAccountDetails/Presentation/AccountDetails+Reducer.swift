//
//  AccountDetails+Reducer.swift
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

extension AccountDetails {

    enum EffectID: Hashable {
        case accountUpdates
    }

    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                // Re-appearing restarts the stream under the same id rather than adding a second one.
                return .merge(
                    observeAccountUpdates,
                    .fireAndForget { [dependencies] in dependencies.refreshAccount() }
                )

            case .accountUpdated(let account):
                state.account = account
                return nil

            case .restoreTapped:
                guard !state.isRestoring else { return nil }
                state.isRestoring = true
                return .task { [dependencies] in
                    .restoreFinished(await dependencies.restorePurchase())
                }

            case .restoreFinished(let result):
                state.isRestoring = false
                switch result {
                case .renewed:
                    state.alert = .restoreSucceeded
                    return .task { [dependencies] in .accountUpdated(dependencies.currentAccount()) }
                case .badReceipt:
                    state.alert = .noRedeemablePurchase
                case .failed(let message):
                    state.alert = .failure(message: message)
                }
                return nil

            case .alertDismissed:
                state.alert = nil
                return nil

            case .manageSubscriptionTapped:
                return .fireAndForget { [dependencies] in dependencies.emit(.manageSubscription) }

            case .deleteAccountTapped:
                return .fireAndForget { [dependencies] in dependencies.emit(.deleteAccount) }
            }
        }

        private var observeAccountUpdates: Effect<Action> {
            .stream(id: EffectID.accountUpdates) { [dependencies] send in
                for await _ in dependencies.accountUpdates() {
                    send(.accountUpdated(dependencies.currentAccount()))
                }
            }
        }
    }
}
