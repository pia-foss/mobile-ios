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

/// Cross-process change observation for the shared-state file.
///
/// The app and the tunnel extension are separate processes, so ordinary `NotificationCenter` / KVO
/// can't signal between them. A **Darwin notification** (device-global, delivered across the process
/// boundary via Mach) is used instead — the mechanism Apple's app-group IPC is built on and the same
/// one PIA uses for its other app↔extension signalling. It carries no payload: the shared file is the
/// single source of truth, so observers simply re-`read()`.
///
/// **Best-effort, not a queue.** Darwin notifications are *not* delivered to a suspended process
/// (posted with `.deliverImmediately` to minimise this), and rapid posts coalesce. So treat this as
/// an optimisation that makes updates prompt when both processes are live — not a guaranteed channel.
/// The file stays authoritative, and reliable read triggers (e.g. the app re-reading on
/// `.PIADaemonsDidUpdateVPNStatus`, the extension reading on every tunnel start) must remain in place.
///
/// `write(_:)` and `delete()` post the signal automatically. Each process opts in with
/// `startObserving()` (once, at launch), then listens via `observe(_:)` or `didChangeNotification`.
extension PIATunnelSharedState {

    // MARK: - Observation

    /// In-process notification re-posted (on the main queue) whenever the shared-state file changes
    /// in *either* process. Carries no payload; handlers should re-`read()`. Prefer `observe(_:)`,
    /// which hands back the freshly-read `State` for you.
    public static let didChangeNotification = Notification.Name("PIATunnelSharedState.didChange")

    /// Device-global Darwin notification name, namespaced by app group so it can't collide with
    /// other apps' notifications.
    private static let darwinNotificationName = "\(AppConstants.appGroup).PIATunnelSharedState.didChange"

    /// Registers the cross-process Darwin observer exactly once and bridges it into
    /// `didChangeNotification` on the main queue. Lazily-initialised `static let` → thread-safe and
    /// idempotent. The callback is a non-capturing C function pointer (required by
    /// `CFNotificationCenterAddObserver`); it only touches globals, so it stays non-capturing.
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

    /// Begins listening for shared-state changes from the other process. Idempotent — call once per
    /// process (e.g. the app in `Bootstrapper`, the extension in `PIAPacketTunnelProvider.start`)
    /// before relying on `didChangeNotification` / `observe(_:)`.
    public static func startObserving() {
        _ = darwinBridge
    }

    /// Observes shared-state changes and hands back the freshly-read `State` on the main queue.
    /// Calls `startObserving()` for you. Returns a token — retain it while interested and pass it to
    /// `NotificationCenter.default.removeObserver(_:)` to stop.
    ///
    /// Note: a process also receives its *own* writes (Darwin notifications have no sender), so
    /// handlers must be idempotent and must not write unconditionally in response — that would loop.
    public static func observe(_ handler: @escaping (State) -> Void) -> NSObjectProtocol {
        startObserving()
        return NotificationCenter.default.addObserver(
            forName: didChangeNotification, object: nil, queue: .main
        ) { _ in
            handler(read())
        }
    }

    /// Posts the cross-process change signal. Called by `write(_:)` / `delete()` after the file is
    /// updated, so every mutator notifies both processes without callers having to remember to.
    static func postDidChange() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(darwinNotificationName as CFString),
            nil,
            nil,
            true)
    }
}
