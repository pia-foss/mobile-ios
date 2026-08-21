//
//  VPNStatus+NetworkExtension.swift
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
import NetworkExtension

extension VPNStatus {
    /// Maps a native NetworkExtension status to its app-level equivalent.
    static func from(nativeStatus: NEVPNStatus) -> VPNStatus {
        switch nativeStatus {
        case .connected:
            return .connected
        case .connecting, .reasserting:
            return .connecting
        case .disconnecting:
            return .disconnecting
        case .disconnected, .invalid:
            return .disconnected
        @unknown default:
            return .unknown
        }
    }

    /// The status the app should adopt once the real status of PIA's VPN configuration is
    /// known at launch, or `nil` when the current status must be left alone.
    ///
    /// - A native `.connected` is hard, PIA-specific evidence and is always adopted. This covers
    ///   a tunnel brought up by on-demand rules while the app was not running.
    /// - Otherwise only an optimistic `.connected` launch seed is corrected. A `.connecting` or
    ///   `.disconnecting` current value can only come from a real `NEVPNStatusDidChange` for our
    ///   own manager, or from the user tapping Connect while the configuration was still
    ///   loading, and must not be clobbered by this late callback.
    static func reconciled(current: VPNStatus, nativeStatus: NEVPNStatus) -> VPNStatus? {
        return reconciled(
            current: current,
            resolved: VPNStatus.from(nativeStatus: nativeStatus),
            isOwnConnectionUp: nativeStatus == .connected
        )
    }

    /// The same adoption policy, expressed over an already-resolved app-level status.
    ///
    /// Under the PlatformSDK tunnel the native status alone is not the whole truth: the NE can be
    /// `.connected` while the tunnel is still (re)connecting, so the caller resolves the two into
    /// `resolved` (see ``VPNStatus/resolve(system:tunnel:)``) and reports separately, via
    /// `isOwnConnectionUp`, whether PIA's own configuration is natively up. That flag — not
    /// `resolved` — is what makes this hard, PIA-specific evidence worth adopting; `resolved` is
    /// then the status actually adopted, so an on-demand tunnel that came up mid-reconnect
    /// surfaces as `.connecting` rather than a premature `.connected`.
    static func reconciled(current: VPNStatus, resolved: VPNStatus, isOwnConnectionUp: Bool) -> VPNStatus? {
        if isOwnConnectionUp {
            return (current == resolved) ? nil : resolved
        }
        guard current == .connected else {
            return nil
        }
        return resolved
    }
}
