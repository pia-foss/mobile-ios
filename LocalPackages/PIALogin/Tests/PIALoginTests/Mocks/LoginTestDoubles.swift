//
//  LoginTestDoubles.swift
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

import Foundation
import PIALibrary

@testable import PIALogin

@MainActor
final class LoginDependencySpy {
    var loginResult: Result<UserAccount, LoginError> = .success(.stub)
    var receiptResult: Result<UserAccount, LoginError> = .success(.stub)
    var tokenResult: Result<UserAccount, LoginError> = .success(.stub)
    var magicLinkResult: Result<Login.Success, LoginError> = .success(Login.Success())
    nonisolated(unsafe) var now = Date(timeIntervalSince1970: 1_000)

    private(set) var loggedInCredentials: [Credentials] = []
    private(set) var receiptLoginCount = 0
    private(set) var redeemedTokens: [String] = []
    private(set) var requestedEmails: [String] = []
    private(set) var emittedOutputs: [Login.Output] = []
    private var tokenContinuation: AsyncStream<String>.Continuation?

    func makeDependencies() -> Login.Dependencies {
        .init(
            login: { [self] credentials in
                loggedInCredentials.append(credentials)
                return loginResult
            },
            loginWithReceipt: { [self] in
                receiptLoginCount += 1
                return receiptResult
            },
            loginWithMagicLinkToken: { [self] token in
                redeemedTokens.append(token)
                return tokenResult
            },
            requestMagicLink: { [self] email in
                requestedEmails.append(email)
                return magicLinkResult
            },
            magicLinkTokens: { [self] in
                AsyncStream { tokenContinuation = $0 }
            },
            now: { [self] in now },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }

    func openMagicLink(token: String) {
        tokenContinuation?.yield(token)
    }
}

extension UserAccount {
    static let stub = UserAccount(credentials: Credentials(username: "p1234567", password: "secret"), info: nil)
}
