//
//  Login+Live.swift
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

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: Login.Dependencies.self)

// The provider is handed in by the host, so nothing here reaches for `Client`.
extension Login.Dependencies {

    /// - Parameters:
    ///   - currentReceipt: Syncs App Store entitlements and returns the receipt to sign in with, or
    ///     `nil` when there is none. Passed in because `InAppProvider`'s async calls can't hop off
    ///     the main actor with a non-`Sendable` provider under Swift 6 checking.
    ///   - magicLinkTokens: Tokens from magic-link deep links opened while the screen is up.
    @MainActor
    public static func live(
        accountProvider: AccountProvider,
        currentReceipt: @MainActor @escaping () async -> LoginReceiptRequest?,
        magicLinkTokens: @MainActor @escaping () -> AsyncStream<String>,
        emit: @MainActor @escaping (Login.Output) -> Void
    ) -> Login.Dependencies {
        Login.Dependencies(
            login: { credentials in
                log.debug("Logging in with credentials")
                return await userAccount { accountProvider.login(with: LoginRequest(credentials: credentials), $0) }
            },
            loginWithReceipt: {
                guard let request = await currentReceipt() else {
                    log.debug("No entitlement found to restore")
                    return .failure(.badReceipt)
                }
                log.debug("Logging in with receipt")
                return await userAccount { accountProvider.login(with: request, $0) }
            },
            loginWithMagicLinkToken: { token in
                log.debug("Logging in with magic link token")
                return await userAccount { accountProvider.login(with: token, $0) }
            },
            requestMagicLink: { email in
                await withCheckedContinuation { continuation in
                    accountProvider.loginUsingMagicLink(withEmail: email) { result in
                        continuation.resume(returning: result.map { Success() }.mapError(LoginError.init))
                    }
                }
            },
            magicLinkTokens: magicLinkTokens,
            emit: emit
        )
    }

    @MainActor
    private static func userAccount(
        _ call: (@escaping ClientCallback<UserAccount>) -> Void
    ) async -> Result<UserAccount, LoginError> {
        await withCheckedContinuation { continuation in
            call { result in
                if case .failure(let error) = result {
                    log.error("Failed to log in: \(error)")
                }
                continuation.resume(returning: result.mapError(LoginError.init))
            }
        }
    }
}
