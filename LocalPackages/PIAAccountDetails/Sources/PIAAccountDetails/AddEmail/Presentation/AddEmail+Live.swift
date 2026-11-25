//
//  AddEmail+Live.swift
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

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: AddEmail.Dependencies.self)

// The provider and the stored values are handed in by the host, so nothing here reaches for `Client`.
extension AddEmail.Dependencies {

    /// `@MainActor` because `AccountProvider` is not `Sendable`: pinning the adapter to one actor is
    /// what allows it to be captured by the dependency closures at all.
    ///
    /// - Parameters:
    ///   - temporaryPassword: The password the backend generated when the email was set
    ///     (`Client.configuration.tempAccountPassword`).
    ///   - clearTemporaryPassword: Forgets that password.
    ///   - storedAppleIDEmail: The email the last Sign in with Apple shared
    ///     (`Client.preferences.signInWithAppleFakeEmail`).
    ///   - storeAppleIDEmail: Remembers it.
    @MainActor
    public static func live(
        accountProvider: AccountProvider,
        temporaryPassword: @MainActor @escaping () -> String,
        clearTemporaryPassword: @MainActor @escaping () -> Void,
        storedAppleIDEmail: @MainActor @escaping () -> String?,
        storeAppleIDEmail: @MainActor @escaping (String) -> Void,
        emit: @MainActor @escaping (AddEmail.Output) -> Void
    ) -> AddEmail.Dependencies {
        AddEmail.Dependencies(
            updateEmail: { email in
                log.debug("Account: Modifying account email...")
                let updated = await withCheckedContinuation { continuation in
                    accountProvider.update(
                        with: UpdateAccountRequest(email: email),
                        resetPassword: true,
                        andPassword: ""
                    ) { info, error in
                        if info == nil {
                            log.error("Account: Failed to modify account email (error: \(String(describing: error)))")
                        }
                        continuation.resume(returning: info != nil)
                    }
                }
                guard updated else { return nil }

                log.debug("Account: Email successfully modified")
                return AddEmail.Credentials(
                    username: accountProvider.publicUsername ?? "",
                    password: temporaryPassword()
                )
            },
            storedAppleIDEmail: storedAppleIDEmail,
            storeAppleIDEmail: storeAppleIDEmail,
            clearTemporaryPassword: clearTemporaryPassword,
            logout: {
                await withCheckedContinuation { continuation in
                    accountProvider.logout { error in
                        if let error {
                            log.error("Account: Error logging out the user (error: \(error))")
                        }
                        continuation.resume(returning: error == nil)
                    }
                }
            },
            emit: emit
        )
    }
}
