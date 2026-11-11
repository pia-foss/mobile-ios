//
//  Login.swift
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

public enum Login {}

extension Login {

    /// A way of signing in. Each one is throttled by the backend independently.
    public enum Method: Hashable, Sendable {
        case credentials
        case receipt
        /// Asking for an email with a sign-in link.
        case magicLink
        /// Signing in with the token from that email's link.
        case magicLinkToken
    }

    public enum Field: Hashable, Sendable {
        case username
        case password
    }

    public enum Alert: Equatable, Sendable {
        /// Restoring from the App Store receipt found nothing usable.
        case badReceipt
    }

    public struct State: Equatable, Sendable {
        public var username: String
        public var password: String
        public var invalidFields: Set<Field>
        /// One request at a time; every control is disabled while this is set.
        public var inFlight: Method?
        /// When each method may be tried again after the backend throttled it.
        public var retryAfter: [Method: Date]
        public var isMagicLinkPromptPresented: Bool
        public var magicLinkEmail: String
        public var alert: Alert?

        public init(
            username: String = "",
            password: String = "",
            invalidFields: Set<Field> = [],
            inFlight: Method? = nil,
            retryAfter: [Method: Date] = [:],
            isMagicLinkPromptPresented: Bool = false,
            magicLinkEmail: String = "",
            alert: Alert? = nil
        ) {
            self.username = username
            self.password = password
            self.invalidFields = invalidFields
            self.inFlight = inFlight
            self.retryAfter = retryAfter
            self.isMagicLinkPromptPresented = isMagicLinkPromptPresented
            self.magicLinkEmail = magicLinkEmail
            self.alert = alert
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case usernameChanged(String)
        case passwordChanged(String)
        case loginTapped
        case receiptLoginTapped
        case restorePurchaseTapped
        case magicLinkTapped
        case magicLinkEmailChanged(String)
        case magicLinkPromptDismissed
        case magicLinkSendTapped
        case magicLinkTokenReceived(String)
        case loginResponse(Method, Result<UserAccount, LoginError>)
        case magicLinkResponse(Result<Success, LoginError>)
        case alertDismissed
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        case didLogin(UserAccount)
        /// The account exists but its plan has run out; the host offers a new one.
        case accountExpired
        /// "Couldn't get your plan?" — the host shows the restore screen.
        case restorePurchaseRequested
        /// A transient error banner. Already localized.
        case showError(message: String, duration: TimeInterval?)
        /// A transient confirmation banner. Already localized.
        case showMessage(String)
    }

    public struct Dependencies: Sendable {
        public var login: @MainActor (Credentials) async -> Result<UserAccount, LoginError>
        public var loginWithReceipt: @MainActor () async -> Result<UserAccount, LoginError>
        public var loginWithMagicLinkToken: @MainActor (String) async -> Result<UserAccount, LoginError>
        public var requestMagicLink: @MainActor (String) async -> Result<Success, LoginError>
        /// Tokens from magic-link deep links, opened while this screen is up.
        public var magicLinkTokens: @MainActor () -> AsyncStream<String>
        public var now: @Sendable () -> Date
        public var emit: @MainActor (Output) -> Void

        public init(
            login: @MainActor @escaping (Credentials) async -> Result<UserAccount, LoginError>,
            loginWithReceipt: @MainActor @escaping () async -> Result<UserAccount, LoginError>,
            loginWithMagicLinkToken: @MainActor @escaping (String) async -> Result<UserAccount, LoginError>,
            requestMagicLink: @MainActor @escaping (String) async -> Result<Success, LoginError>,
            magicLinkTokens: @MainActor @escaping () -> AsyncStream<String>,
            now: @Sendable @escaping () -> Date = { Date() },
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.login = login
            self.loginWithReceipt = loginWithReceipt
            self.loginWithMagicLinkToken = loginWithMagicLinkToken
            self.requestMagicLink = requestMagicLink
            self.magicLinkTokens = magicLinkTokens
            self.now = now
            self.emit = emit
        }
    }
}
