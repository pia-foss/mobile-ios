//
//  WelcomeBackTestDoubles.swift
//  PIAPaywallTests
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

import Foundation
import PIALibrary

@testable import PIAPaywall

extension WelcomeBack.Dependencies {
    static func test(
        restore: @escaping () async -> Result<UserAccount, PaywallError> = { .success(Stub.user) },
        emit: @escaping (WelcomeBack.Output) -> Void = { _ in }
    ) -> WelcomeBack.Dependencies {
        WelcomeBack.Dependencies(restore: restore, emit: emit)
    }
}

final class WelcomeBackDependencySpy: @unchecked Sendable {
    private(set) var restoreCallCount = 0
    private(set) var emittedOutputs: [WelcomeBack.Output] = []

    var restoreResult: Result<UserAccount, PaywallError> = .success(Stub.user)

    func makeDependencies() -> WelcomeBack.Dependencies {
        WelcomeBack.Dependencies(
            restore: { [self] in
                restoreCallCount += 1
                return restoreResult
            },
            emit: { [self] output in
                emittedOutputs.append(output)
            }
        )
    }

    var authenticatedUsers: [UserAccount] {
        emittedOutputs.compactMap { if case .didAuthenticate(let user) = $0 { return user } else { return nil } }
    }

    var didRequestLogin: Bool {
        emittedOutputs.contains { if case .requestLogin = $0 { return true } else { return false } }
    }

    var didDismiss: Bool {
        emittedOutputs.contains { if case .didDismiss = $0 { return true } else { return false } }
    }
}
