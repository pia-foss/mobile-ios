//
//  ValidateQRLoginTestDoubles.swift
//  PIAValidateQRLoginTests
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

@testable import PIAValidateQRLogin

final class ValidateQRLoginDependencySpy: @unchecked Sendable {
    private(set) var validateCallCount = 0
    private(set) var discardCallCount = 0
    private(set) var emittedOutputs: [ValidateQRLogin.Output] = []
    var validateResult: Result<Void, any Error> = .success(())

    func makeDependencies() -> ValidateQRLogin.Dependencies {
        .init(
            validate: { [self] in
                validateCallCount += 1
                return validateResult
            },
            discardQRToken: { [self] in discardCallCount += 1 },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }
}

struct ValidateQRLoginTestError: Error {}
