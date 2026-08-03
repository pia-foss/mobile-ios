//
//  Data+Base64URL.swift
//  PIABase
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

extension Data {

    /// Initializes a data object with the given base64url encoded string, the
    /// URL- and filename-safe alphabet defined in RFC 4648 §5.
    ///
    /// It is the counterpart of `Data(base64Encoded:)` for the encoding used by
    /// JWT/JWS and friends: `-` and `_` replace `+` and `/`, and the trailing
    /// `=` padding is usually dropped. Both padded and unpadded input is
    /// accepted; input using the standard base64 alphabet is rejected.
    ///
    /// - Parameter base64UrlEncoded: The base64url encoded string.
    /// - Returns: `nil` when the string is not valid base64url.
    public init?(base64UrlEncoded string: String) {
        // + and / belong to the standard alphabet only, and would otherwise
        // survive the translation below and decode as if they were base64url.
        guard !string.contains("+"), !string.contains("/") else { return nil }

        var base64 =
            string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        switch remainder {
        case 0:
            break
        case 2, 3:
            base64.append(String(repeating: "=", count: 4 - remainder))
        default:
            // A single leftover character can never encode a whole byte.
            return nil
        }

        guard let data = Data(base64Encoded: base64) else { return nil }
        self = data
    }

    /// Returns a base64url encoded string, using the URL- and filename-safe
    /// alphabet defined in RFC 4648 §5 and omitting the trailing `=` padding as
    /// JWT/JWS require.
    public func base64UrlEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
