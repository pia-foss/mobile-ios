//
//  PIATunnelSharedState+Observation.swift
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

/// Cross-process change observation for the shared state.
///
/// `NotificationCenter` can't cross the app/extension process boundary, so a Darwin notification is
/// used instead. It carries no payload — the files are the source of truth, so observers re-read.
///
/// **Best-effort, not a queue**: Darwin notifications aren't delivered to a suspended process and
/// rapid posts coalesce. Reliable read triggers (the app on `.PIADaemonsDidUpdateVPNStatus`, the
/// extension on every tunnel start) must stay in place. Each process opts in once via
/// `startObserving()`; the mutators post the signal themselves.
extension PIATunnelSharedState {

    // MARK: - Observation

    /// Re-posted on the main queue whenever the shared state changes in *either* process. Carries no
    /// payload; handlers re-read.
    public static let didChangeNotification = Notification.Name("PIATunnelSharedState.didChange")

    /// Namespaced by app group so it can't collide with other apps.
    private static let darwinNotificationName = "\(AppConstants.appGroup).PIATunnelSharedState.didChange"

    /// Registers the Darwin observer once and bridges it to `didChangeNotification` on the main queue.
    /// Lazy `static let` → thread-safe and idempotent. The callback must stay non-capturing, as
    /// `CFNotificationCenterAddObserver` takes a C function pointer.
    private static let darwinBridge: Void = {
        let onDarwinNotification: CFNotificationCallback = { _, _, _, _, _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PIATunnelSharedState.didChangeNotification, object: nil)
            }
        }
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            onDarwinNotification,
            darwinNotificationName as CFString,
            nil,
            .deliverImmediately)
        return ()
    }()

    /// Begins listening for changes. Idempotent; call once per process (the app in `Bootstrapper`, the
    /// extension in `PIAPacketTunnelProvider.start`). A process also receives its *own* writes — Darwin
    /// notifications have no sender — so handlers must be idempotent and must not write unconditionally.
    public static func startObserving() {
        _ = darwinBridge
    }

    /// Posts the change signal. Called by `Store` after a write or delete, so every mutator notifies
    /// both processes without callers having to remember to.
    static func postDidChange() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(darwinNotificationName as CFString),
            nil,
            nil,
            true)
    }
}
