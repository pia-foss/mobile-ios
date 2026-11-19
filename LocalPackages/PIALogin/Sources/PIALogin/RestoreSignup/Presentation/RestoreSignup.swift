//
//  RestoreSignup.swift
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

/// Re-sends the account details for a purchase whose signup never completed.
public enum RestoreSignup {}

extension RestoreSignup {

    public struct State: Equatable, Sendable {
        public var email: String
        public var isEmailInvalid: Bool
        public var isRestoring: Bool

        public init(email: String = "", isEmailInvalid: Bool = false, isRestoring: Bool = false) {
            self.email = email
            self.isEmailInvalid = isEmailInvalid
            self.isRestoring = isRestoring
        }
    }

    public enum Action: Equatable, Sendable {
        case emailChanged(String)
        case submitTapped
        case restoreResponse(Result<Success, RestoreSignupError>)
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        /// The receipt is synced; the host creates the account for `email`.
        case didRestore(email: String)
        /// A transient error banner. Already localized.
        case showError(message: String)
    }

    public struct Dependencies: Sendable {
        /// Syncs the purchase history with the App Store.
        public var restorePurchases: @MainActor () async -> Result<Success, RestoreSignupError>
        public var emit: @MainActor (Output) -> Void

        public init(
            restorePurchases: @MainActor @escaping () async -> Result<Success, RestoreSignupError>,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.restorePurchases = restorePurchases
            self.emit = emit
        }
    }
}
