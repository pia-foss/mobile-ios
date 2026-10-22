//
//  WidgetConnectToken.swift
//  PIALibrary
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

// Shared secret between the app and the widget, so only the widget can toggle the VPN via `piavpn:connect` (iOS 15/16).
public final class WidgetConnectToken {
    private static let key = "vpn.widget.connect.token"
    private static let byteCount = 32

    private let defaults: UserDefaults?

    public init(defaults: UserDefaults? = UserDefaults(suiteName: AppConstants.appGroup)) {
        self.defaults = defaults
    }

    public var current: String? {
        defaults?.string(forKey: Self.key)
    }

    public var connectURL: URL? {
        ensureExists()
        guard let current, var components = URLComponents(string: AppConstants.Widget.connect) else {
            return nil
        }
        components.queryItems = [URLQueryItem(name: AppConstants.Widget.tokenQueryItem, value: current)]
        return components.url
    }

    @discardableResult
    public func ensureExists() -> Bool {
        guard current == nil else {
            return false
        }
        rotate()
        return true
    }

    public func consume(from url: URL) -> Bool {
        let candidate = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == AppConstants.Widget.tokenQueryItem }?
            .value

        guard let candidate, let current, Self.constantTimeEquals(candidate, current) else {
            return false
        }
        rotate()
        return true
    }

    private func rotate() {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<Self.byteCount).map { _ in UInt8.random(in: .min ... .max, using: &generator) }
        let token = Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        defaults?.set(token, forKey: Self.key)
    }

    private static func constantTimeEquals(_ lhs: String, _ rhs: String) -> Bool {
        let lhs = Array(lhs.utf8)
        let rhs = Array(rhs.utf8)
        guard lhs.count == rhs.count else {
            return false
        }
        return zip(lhs, rhs).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
