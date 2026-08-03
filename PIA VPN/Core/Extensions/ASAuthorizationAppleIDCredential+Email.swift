//
//  ASAuthorizationAppleIDCredential+Email.swift
//  PIA VPN
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

import AuthenticationServices
import Foundation
import PIABase
import PIALibrary

/// Decodes the claims Apple only exposes inside the identity token JWT.
enum AppleIDIdentityToken {

    private struct Claims: Decodable {
        let email: String?
    }

    /// Returns the `email` claim of an Apple identity token, or `nil` when the
    /// token is malformed or carries no email.
    ///
    /// The signature is not verified: the token comes straight from
    /// `AuthenticationServices` in-process, and the value is only used to
    /// prefill the email field for an account update the backend validates.
    static func email(fromIdentityToken identityToken: Data) -> String? {
        guard let token = String(data: identityToken, encoding: .utf8) else { return nil }

        let segments = token.split(separator: ".", omittingEmptySubsequences: false)
        guard segments.count == 3, let payload = Data(base64UrlEncoded: String(segments[1])) else {
            return nil
        }

        let email = try? JSONDecoder().decode(Claims.self, from: payload).email
        guard let email, !email.isEmpty else { return nil }
        return email
    }
}

private let log = PIALogger.logger(for: ASAuthorizationAppleIDCredential.self)

// `ASAuthorizationAppleIDCredential.email` is a convenience property that Apple
// populates on the *first* authorization for a given app only. On every
// subsequent authorization it is `nil`, even when the email scope is still
// granted. The `identityToken` JWT, on the other hand, carries the `email`
// claim on every successful authorization, so decoding it locally is the
// supported way to recover the address.
extension ASAuthorizationAppleIDCredential {
    /// The user's email, preferring the convenience property and falling back to
    /// the `email` claim of the identity token when Apple omits it.
    var resolvedEmail: String? {
        if let email, !email.isEmpty {
            log.debug("Returning email from credential")
            return email
        }
        if let identityToken, let email = AppleIDIdentityToken.email(fromIdentityToken: identityToken), !email.isEmpty {
            log.debug("Returning email from identity token")
            return email
        }
        log.debug("Unable to find email to return")
        return nil
    }
}
