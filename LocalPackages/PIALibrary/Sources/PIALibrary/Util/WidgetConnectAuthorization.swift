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

/// Where the widget connect secrets are kept between the app and the widget.
public protocol WidgetConnectSecretStore {
    func readSecrets() -> WidgetConnectSecrets?
    func write(_ secrets: WidgetConnectSecrets)
}

/// Asks the widgets to re-render, so they pick up the new connect URL.
public protocol WidgetsReloader {
    func reloadWidgets()
}

private let log = PIALogger.logger(for: WidgetConnectAuthorization.self)

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
    private var reloader: WidgetsReloader?

    public init(
        store: WidgetConnectSecretStore = UserDefaultsWidgetConnectSecretStore(),
        reloader: WidgetsReloader? = nil
    ) {
        self.store = store
        self.reloader = reloader
    }

    /// Registers what to notify once a new secret is stored.
    public func setReloader(_ reloader: WidgetsReloader) {
        lock.lock()
        defer { lock.unlock() }

        self.reloader = reloader
    }

    /// Stores a new secret, keeping the replaced one acceptable for one more generation.
    ///
    /// Called on every cold start.
    public func rotateSecret() {
        storeNewSecret(keepingPrevious: true)
    }

    /// Stores a new secret and drops the previous one, so no URL built before this call is accepted.
    ///
    /// Called on logout.
    public func resetSecret() {
        storeNewSecret(keepingPrevious: false)
    }

    /// The URL the widget opens to toggle the VPN connection, carrying the shared secret.
    public func makeConnectURL() -> URL? {
        guard let secrets = storedSecrets(),
            var components = URLComponents(string: AppConstants.Widget.connect)
        else {
            log.error("Could not build an authorized widget connect URL")
            return nil
        }
        components.queryItems = [URLQueryItem(name: Self.tokenQueryItemName, value: secrets.current)]
        return components.url
    }

    /// Whether the given VPN toggle URL comes from our own widget.
    public func isAuthorized(_ url: URL) -> Bool {
        guard let secrets = storedSecrets() else {
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

        if Self.areEqualInConstantTime(token, secrets.current) {
            return true
        }

        guard let previous = secrets.previous, Self.areEqualInConstantTime(token, previous) else {
            return false
        }

        log.debug("Widget connect URL authorized with the previous secret, the widget has not redrawn yet")
        return true
    }

    // MARK: Private

    private func storeNewSecret(keepingPrevious: Bool) {
        // Keep the stored secrets untouched when the randomness fails: a stale but working URL beats a dead one.
        guard let secret = Self.makeSecret() else { return }

        lock.lock()
        let previous = keepingPrevious ? store.readSecrets()?.current : nil
        store.write(WidgetConnectSecrets(current: secret, previous: previous))
        let reloader = self.reloader
        lock.unlock()

        // Outside the lock: the reloader reaches out to WidgetKit and ActivityKit.
        reloader?.reloadWidgets()
    }

    private func storedSecrets() -> WidgetConnectSecrets? {
        lock.lock()
        defer { lock.unlock() }

        return store.readSecrets()
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

/// The secret in use, plus the one it just replaced.
public struct WidgetConnectSecrets: Equatable, Sendable {
    public let current: String
    public let previous: String?

    public init(current: String, previous: String? = nil) {
        self.current = current
        self.previous = previous
    }
}

/// Keeps the secrets in the app group container, readable by the app and its extensions only.
public struct UserDefaultsWidgetConnectSecretStore: WidgetConnectSecretStore {

    private static let currentKey = "vpn.widget.connect.secret"
    private static let previousKey = "vpn.widget.connect.secret.previous"

    private let defaults: UserDefaults

    public init(group: String = AppConstants.appGroup) {
        guard let defaults = UserDefaults(suiteName: group) else {
            log.error("Unable to create UserDefaults for app group")
            fatalError("No app group container")
        }
        self.defaults = defaults
    }

    public func readSecrets() -> WidgetConnectSecrets? {
        guard let current = secret(forKey: Self.currentKey) else {
            return nil
        }
        return WidgetConnectSecrets(current: current, previous: secret(forKey: Self.previousKey))
    }

    public func write(_ secrets: WidgetConnectSecrets) {
        defaults.set(secrets.current, forKey: Self.currentKey)
        if let previous = secrets.previous {
            defaults.set(previous, forKey: Self.previousKey)
        } else {
            defaults.removeObject(forKey: Self.previousKey)
        }
    }

    private func secret(forKey key: String) -> String? {
        guard let secret = defaults.string(forKey: key), !secret.isEmpty else {
            return nil
        }
        return secret
    }
}
