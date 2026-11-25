//
//  AddEmail.swift
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

/// Asks a logged-in account with no email to set one, then shows the credentials the backend
/// generated for it. The screen can't be dismissed until the email is set or the person logs out.
public enum AddEmail {}

extension AddEmail {

    /// The username and the password the backend reset when the email was set.
    public struct Credentials: Equatable, Sendable {
        public var username: String
        public var password: String

        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }

    public enum Step: Equatable, Sendable {
        case form
        /// The email was set; shows the credentials sent to it.
        case done(email: String, credentials: Credentials)
    }

    public enum Alert: Hashable, Identifiable, Sendable {
        /// Asks to agree to the data collection before the email is sent.
        case consent
        case updateFailed

        public var id: Self { self }
    }

    public struct State: Equatable {
        public var email: String
        public var emailError: Validator.EmailValidationError?
        /// Asked once per screen, then remembered for later submits.
        public var hasConsented: Bool
        public var isSubmitting: Bool
        public var isLoggingOut: Bool
        public var alert: Alert?
        public var step: Step

        public init(
            email: String = "",
            emailError: Validator.EmailValidationError? = nil,
            hasConsented: Bool = false,
            isSubmitting: Bool = false,
            isLoggingOut: Bool = false,
            alert: Alert? = nil,
            step: Step = .form
        ) {
            self.email = email
            self.emailError = emailError
            self.hasConsented = hasConsented
            self.isSubmitting = isSubmitting
            self.isLoggingOut = isLoggingOut
            self.alert = alert
            self.step = step
        }
    }

    public enum Action: Equatable {
        case emailChanged(String)
        case submitTapped
        case consentGiven
        case alertDismissed
        /// Sign in with Apple finished; `nil` when Apple shared no email.
        case appleIDAuthorized(email: String?)
        case appleIDEmailResolved(String?)
        case updateSucceeded(email: String, credentials: Credentials)
        case updateFailed
        case closeTapped
        case logoutTapped
        case logoutFinished(succeeded: Bool)
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        /// The email is set and the credentials were seen.
        case finished
        /// The person logged out instead of setting an email.
        case loggedOut
    }

    public struct Dependencies: Sendable {
        /// Sets the account email, which also resets its password. `nil` when the update failed.
        public var updateEmail: @MainActor (String) async -> Credentials?
        /// The email the last Sign in with Apple shared, for when Apple doesn't share it again.
        public var storedAppleIDEmail: @MainActor () -> String?
        public var storeAppleIDEmail: @MainActor (String) -> Void
        /// Forgets the generated password once it has been shown.
        public var clearTemporaryPassword: @MainActor () -> Void
        public var logout: @MainActor () async -> Bool
        public var emit: @MainActor (Output) -> Void

        public init(
            updateEmail: @MainActor @escaping (String) async -> Credentials?,
            storedAppleIDEmail: @MainActor @escaping () -> String?,
            storeAppleIDEmail: @MainActor @escaping (String) -> Void,
            clearTemporaryPassword: @MainActor @escaping () -> Void,
            logout: @MainActor @escaping () async -> Bool,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.updateEmail = updateEmail
            self.storedAppleIDEmail = storedAppleIDEmail
            self.storeAppleIDEmail = storeAppleIDEmail
            self.clearTemporaryPassword = clearTemporaryPassword
            self.logout = logout
            self.emit = emit
        }
    }
}
