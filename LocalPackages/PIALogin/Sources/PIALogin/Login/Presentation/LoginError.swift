//
//  LoginError.swift
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

import PIALibrary
import PIALocalizations

/// Everything that can go wrong signing in, reduced to the cases the screen treats differently.
///
/// `ClientError` is mapped once, in `Login+Live`, because its own descriptions are not localized.
public enum LoginError: Error, Equatable, Sendable {
    case unauthorized
    case throttled(retryAfter: UInt)
    case expired
    /// No receipt to restore from, or the backend rejected it.
    case badReceipt
    case internetUnreachable
    case backendUnavailable
    case `internal`(code: Int)
    case unknown(message: String, code: Int)
}

extension LoginError {
    init(_ error: ClientError) {
        switch error {
        case .unauthorized: self = .unauthorized
        case .throttled(let retryAfter): self = .throttled(retryAfter: retryAfter)
        case .expired: self = .expired
        case .noReceipt, .badReceipt: self = .badReceipt
        case .internetUnreachable: self = .internetUnreachable
        case .backendUnavailable: self = .backendUnavailable
        case .libraryError(let code, _): self = .internal(code: code)
        case .unknown(let code, let message): self = .unknown(message: message, code: code)
        default: self = .unknown(message: error.localizedDescription, code: 0)
        }
    }

    var message: String {
        switch self {
        case .unauthorized: L10n.Welcome.Login.Error.unauthorized
        case .throttled(let retryAfter): L10n.Welcome.Login.Error.throttled("\(retryAfter)")
        case .expired, .badReceipt: L10n.Account.Restore.Failure.message
        case .internetUnreachable: L10n.Global.unreachable
        case .backendUnavailable: L10n.Welcome.Login.Error.backendUnavailable
        case .internal(let code): L10n.Signup.Failure.internal(code)
        case .unknown(let message, let code): L10n.Signup.Failure.unknown(message, code)
        }
    }
}
