//
//  PlatformSDKMigrationDecision.swift
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

import Foundation
import PIALibrary

/// The decisions the PlatformSDK migration makes, split out from the NetworkExtension plumbing so
/// they can be tested without a device.
enum PlatformSDKMigrationDecision {

    /// Whether deleting the legacy configurations owes the user a reconnect.
    ///
    /// A live Network Extension status alone is not enough: an app upgrade tears the extension
    /// down, so the tunnel can read `.disconnected` at launch while on-demand is still armed and
    /// about to bring it back. Armed on-demand rules and the persisted status are the two signals
    /// that survive that window, and any of the three means the user wanted the VPN up.
    static func shouldReconnectAfterCleanup(
        isNativeLive: Bool,
        isOnDemandArmed: Bool,
        lastKnownStatus: VPNStatus
    ) -> Bool {
        return isNativeLive || isOnDemandArmed || lastKnownStatus == .connected
    }

    /// Whether the migration owes the user a reconnect, judged from the status persisted across
    /// launches. Only valid before `Client.bootstrap()`, which reconciles that status away.
    ///
    /// Two cases qualify: a cleanup that has not run yet and is about to delete the live tunnel,
    /// and one that already ran on a build with no such flag — 3.36, which could delete the tunnel
    /// and then miss its one-shot reconnect. A recorded answer is never second-guessed.
    static func shouldOweReconnectBeforeBootstrap(
        usesPlatformSDKTunnel: Bool,
        didCleanup: Bool,
        hasStoredValue: Bool,
        lastKnownStatus: VPNStatus
    ) -> Bool {
        guard usesPlatformSDKTunnel, lastKnownStatus == .connected else {
            return false
        }
        return !didCleanup || !hasStoredValue
    }
}
