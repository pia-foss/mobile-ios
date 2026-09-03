//
//  WelcomeBack+Reducer.swift
//  PIAPaywall
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

extension WelcomeBack {
    struct Reducer {
        typealias State = WelcomeBack.State
        typealias Action = WelcomeBack.Action

        fileprivate enum EffectID: Hashable {
            case restore
        }

        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .appStoreAccountTapped: return beginRestore(in: &state)
            case .restoreSucceeded(let account): return completeRestore(account, in: &state)
            case .restoreFailed: return failRestore(in: &state)
            case .usernameAndPasswordTapped: return requestLogin(in: state)
            }
        }
    }
}

extension WelcomeBack.Reducer {

    private func beginRestore(in state: inout State) -> Effect<Action>? {
        guard !state.isRestoring else { return nil }
        state.isRestoring = true
        return restore
    }

    private func completeRestore(_ account: AccountBox, in state: inout State) -> Effect<Action>? {
        state.isRestoring = false
        return emit(.didAuthenticate(user: account.value))
    }

    private func failRestore(in state: inout State) -> Effect<Action>? {
        state.isRestoring = false
        return emit(.didDismiss)
    }

    private func requestLogin(in state: State) -> Effect<Action>? {
        guard !state.isRestoring else { return nil }
        return emit(.requestLogin)
    }

    fileprivate var restore: Effect<Action> {
        .cancellableTask(id: EffectID.restore) { [dependencies] in
            switch await dependencies.restore() {
            case .success(let user):
                return .restoreSucceeded(.init(user))
            case .failure:
                return .restoreFailed
            }
        }
    }

    fileprivate func emit(_ output: WelcomeBack.Output) -> Effect<Action> {
        .fireAndForget { [dependencies] in dependencies.emit(output) }
    }
}
