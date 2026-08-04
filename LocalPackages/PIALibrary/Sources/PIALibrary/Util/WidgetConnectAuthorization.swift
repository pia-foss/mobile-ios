//
//  WidgetConnectAuthorization.swift
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
import Security

private let log = PIALogger.logger(for: WidgetConnectAuthorization.self)

/// Where the widget connect secret is kept between the app and the widget.
public protocol WidgetConnectSecretStore {
    func readSecret() -> String?
    func write(_ secret: String)
    func clear()
}

/// Authorizes the widget initiated VPN toggle deep link.
///
/// Any other app can also open PIA via the `piavpn:connect` URL, forcing the user to connect or
/// disconnect. To tell our own widget apart, the widget appends a secret shared through the app group
/// container: only the app and its own extensions can read it, so a URL built by another app never
/// carries a valid token.
public final class WidgetConnectAuthorization {

    public static let shared = WidgetConnectAuthorization()

    private static let tokenQueryItemName = "secret"
    private static let secretByteCount = 32

    private let store: WidgetConnectSecretStore
    private let lock = NSLock()

    public init(store: WidgetConnectSecretStore = UserDefaultsWidgetConnectSecretStore()) {
        self.store = store
    }

    /// Creates and stores the secret unless one already exists.
    public func createSecretIfNeeded() {
        lock.lock()
        defer { lock.unlock() }

        guard store.readSecret() == nil else { return }

        guard let secret = Self.makeSecret() else { return }
        store.write(secret)
    }

    /// Removes the secret from storage
    public func clearSecret() {
        lock.lock()
        defer { lock.unlock() }
        store.clear()
    }

    /// The URL the widget opens to toggle the VPN connection, carrying the shared secret.
    public func makeConnectURL() -> URL? {
        guard let secret = storedSecret(),
            var components = URLComponents(string: AppConstants.Widget.connect)
        else {
            log.error("Could not build an authorized widget connect URL")
            return nil
        }
        components.queryItems = [URLQueryItem(name: Self.tokenQueryItemName, value: secret)]
        return components.url
    }

    /// Whether the given VPN toggle URL comes from our own widget.
    public func isAuthorized(_ url: URL) -> Bool {
        guard let secret = storedSecret() else {
            log.error("No widget connect secret stored yet, rejecting the URL")
            return false
        }

        guard
            let token = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == Self.tokenQueryItemName })?
                .value
        else {
            log.error("Widget connect URL without a token, rejecting it")
            return false
        }

        return Self.areEqualInConstantTime(token, secret)
    }

    // MARK: Private

    private func storedSecret() -> String? {
        lock.lock()
        defer { lock.unlock() }

        return store.readSecret()
    }

    private static func makeSecret() -> String? {
        var bytes = [UInt8](repeating: 0, count: secretByteCount)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            log.error("Could not generate a random widget connect secret")
            return nil
        }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    /// Compares the two secrets without leaking their content through the comparison time.
    private static func areEqualInConstantTime(_ lhs: String, _ rhs: String) -> Bool {
        let lhsBytes = Array(lhs.utf8)
        let rhsBytes = Array(rhs.utf8)

        guard lhsBytes.count == rhsBytes.count else {
            return false
        }

        var difference: UInt8 = 0
        for (lhsByte, rhsByte) in zip(lhsBytes, rhsBytes) {
            difference |= lhsByte ^ rhsByte
        }
        return difference == 0
    }
}

/// Keeps the secret in the app group container, readable by the app and its extensions only.
public struct UserDefaultsWidgetConnectSecretStore: WidgetConnectSecretStore {

    private static let key = "vpn.widget.connect.secret"

    private let defaults: UserDefaults?

    public init(group: String = AppConstants.appGroup) {
        self.defaults = UserDefaults(suiteName: group)
    }

    public func readSecret() -> String? {
        guard let secret = defaults?.string(forKey: Self.key), !secret.isEmpty else {
            return nil
        }
        return secret
    }

    public func write(_ secret: String) {
        guard let defaults else {
            log.error("Could not store the widget connect secret, no app group container")
            return
        }
        defaults.set(secret, forKey: Self.key)
    }

    public func clear() {
        defaults?.removeObject(forKey: Self.key)
    }
}
