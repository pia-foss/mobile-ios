//
//  SideMenu+Reducer.swift
//  PIASideMenu
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

extension SideMenu {

    enum EffectID: Hashable {
        case accountUpdates
    }

    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                // Re-appearing restarts the stream under the same id rather than adding a second one.
                return observeAccount

            case .accountUpdated(let account):
                state.account = account
                return nil

            case .itemTapped(.destination(let destination)):
                return emit(.show(destination))

            case .itemTapped(.website(let website)):
                return emit(.open(website))

            case .itemTapped(.logout):
                state.alert = .logoutConfirmation
                return nil

            case .manageSubscriptionTapped:
                return emit(.manageSubscription)

            case .expirationTapped:
                guard !state.isLoading else { return nil }
                state.isLoading = true
                return .task { [dependencies] in .renewalFinished(await dependencies.renew()) }

            case .renewalFinished(let result):
                state.isLoading = false
                state.alert = result.alert
                return nil

            case .logoutConfirmed:
                state.alert = nil
                guard !state.isLoading else { return nil }
                state.isLoading = true
                return .task { [dependencies] in
                    await dependencies.logout()
                    return .logoutFinished
                }

            case .logoutFinished:
                state.isLoading = false
                return nil

            case .upgradeTrialConfirmed:
                state.alert = nil
                return emit(.upgradeTrial)

            case .renewOnWebsiteConfirmed:
                state.alert = nil
                return emit(.open(.home))

            case .alertDismissed:
                state.alert = nil
                return nil
            }
        }

        private func emit(_ output: Output) -> Effect<Action> {
            .fireAndForget { [dependencies] in dependencies.emit(output) }
        }

        private var observeAccount: Effect<Action> {
            .stream(id: EffectID.accountUpdates) { [dependencies] send in
                send(.accountUpdated(dependencies.currentAccount()))
                for await _ in dependencies.accountUpdates() {
                    send(.accountUpdated(dependencies.currentAccount()))
                }
            }
        }
    }
}

extension SideMenu.RenewalResult {
    fileprivate var alert: SideMenu.Alert? {
        switch self {
        case .renewed: .renewalSucceeded
        case .cancelled: nil
        case .trial: .renewingTrial
        case .nonRenewable: .renewingNonRenewable
        case .failed(let message): .failure(message: message)
        }
    }
}
