//
//  AddEmailTestDoubles.swift
//  PIAAccountDetailsTests
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

@testable import PIAAccountDetails

@MainActor
final class AddEmailDependencySpy {
    /// What `updateEmail` returns; `nil` fails the update.
    var updateResult: AddEmail.Credentials? = .stub
    var storedAppleIDEmail: String?
    var logoutSucceeds = true

    private(set) var updatedEmails: [String] = []
    private(set) var storedAppleIDEmails: [String] = []
    private(set) var clearPasswordCallCount = 0
    private(set) var logoutCallCount = 0
    private(set) var emittedOutputs: [AddEmail.Output] = []

    func makeDependencies() -> AddEmail.Dependencies {
        .init(
            updateEmail: { [self] email in
                updatedEmails.append(email)
                return updateResult
            },
            storedAppleIDEmail: { [self] in storedAppleIDEmail },
            storeAppleIDEmail: { [self] email in storedAppleIDEmails.append(email) },
            clearTemporaryPassword: { [self] in clearPasswordCallCount += 1 },
            logout: { [self] in
                logoutCallCount += 1
                return logoutSucceeds
            },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }
}

extension AddEmail.Credentials {
    static let stub = AddEmail.Credentials(username: "p1234567", password: "x7Kq2mPz")
}
