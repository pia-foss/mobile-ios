//
//  PIATunnelSignal.swift
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

/// Signals crossing the app/tunnel process boundary, carried by Darwin notifications because
/// `NotificationCenter` can't cross it. They carry no payload and are best-effort — a suspended
/// process misses them and rapid posts coalesce, per name — so a signal is only ever a prod to act on
/// state that is already persisted, never the record of what happened. Reliable read triggers (the app
/// on `.PIADaemonsDidUpdateVPNStatus`, the extension on every tunnel start) must stay in place.
///
/// Each process opts in once via `startObserving()`; signals then arrive as `notificationName` on the
/// main queue. A process also receives its own posts — Darwin notifications have no sender — so
/// handlers must be idempotent and must not write unconditionally.
public enum PIATunnelSignal: String, CaseIterable, Sendable {

    /// `PIATunnelSharedState` was written or deleted in either process; observers re-read. Posted by
    /// `Store`, so every mutator notifies both processes without callers having to remember to.
    case sharedStateDidChange

    /// The user's pinned protocol keeps failing and the app should offer switching to Automatic (KM-18462).
    case switchToAutomaticSuggested

    /// The tunnel generated a new batch of connection configurations; observers re-request it with
    /// `PIAPacketTunnelRequest.connectionConfigurations`. Unlike the other signals the state it prods
    /// for lives in the extension's memory rather than on disk, so the re-read is an IPC round-trip.
    case connectionConfigurationsDidChange

    /// Namespaced by app group so it can't collide with other apps.
    private static let darwinNamePrefix = "\(AppConstants.appGroup).PIATunnelSignal."

    public var notificationName: Notification.Name {
        Notification.Name("PIATunnelSignal.\(rawValue)")
    }

    private var darwinName: String {
        Self.darwinNamePrefix + rawValue
    }

    private init?(darwinName: String) {
        guard darwinName.hasPrefix(Self.darwinNamePrefix) else {
            return nil
        }

        self.init(rawValue: String(darwinName.dropFirst(Self.darwinNamePrefix.count)))
    }

    // MARK: - Observation

    public static func startObserving() {
        _ = darwinBridge
    }

    // Lazy `static let` → thread-safe and idempotent. The callback must stay non-capturing, as
    // `CFNotificationCenterAddObserver` takes a C function pointer.
    private static let darwinBridge: Void = {
        let onDarwinNotification: CFNotificationCallback = { _, _, name, _, _ in
            guard let name, let signal = PIATunnelSignal(darwinName: name.rawValue as String) else {
                return
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: signal.notificationName, object: nil)
            }
        }

        let center = CFNotificationCenterGetDarwinNotifyCenter()
        for signal in allCases {
            CFNotificationCenterAddObserver(center, nil, onDarwinNotification, signal.darwinName as CFString, nil, .deliverImmediately)
        }

        return ()
    }()

    // MARK: - Posting

    public func post() {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(darwinName as CFString), nil, nil, true)
    }
}
