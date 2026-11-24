//
//  RestoreSignupTestDoubles.swift
//  PIALoginTests
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

@testable import PIALogin

@MainActor
final class RestoreSignupDependencySpy {
    var restoreResult: Result<Success, RestoreSignupError> = .success(Success())
    private(set) var restoreCallCount = 0
    private(set) var emittedOutputs: [RestoreSignup.Output] = []

    func makeDependencies() -> RestoreSignup.Dependencies {
        .init(
            restorePurchases: { [self] in
                restoreCallCount += 1
                return restoreResult
            },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }
}
