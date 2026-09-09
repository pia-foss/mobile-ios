//
//  SelectableVPNProtocol.swift
//  PIA Common
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

/// The VPN protocols the PlatformSDK tunnel can run, and how a persisted
/// `Client.preferences.vpnType` string maps onto them.
///
/// iOS and tvOS offer the same three, so this is shared: the Protocol settings screens on both
/// platforms read the stored value through it, and both one-time upgrade migrations rewrite the
/// value through it. Keeping the read side and the write side on one definition is the point —
/// they cannot disagree about whether a persisted value is still selectable.
enum SelectableVPNProtocol {

    /// The protocols offered on the Protocol settings screens, in display order.
    static let all: [KapePlatformSDKVPNType] = [.automatic, .wireGuard, .openVPN]

    /// The protocol a persisted `vpnType` means.
    ///
    /// Anything outside ``all`` — the legacy `"IKEv2"` left behind by a pre-PlatformSDK install, or
    /// a value this build does not recognise — resolves to `.automatic`.
    static func resolved(fromStored storedVPNType: String) -> KapePlatformSDKVPNType {
        guard let stored = KapePlatformSDKVPNType(rawValue: storedVPNType), all.contains(stored) else {
            return .automatic
        }
        return stored
    }

    /// The protocol an upgrading install must be moved to, or `nil` when the stored value is already
    /// selectable and must be left alone.
    static func migration(fromStored storedVPNType: String) -> KapePlatformSDKVPNType? {
        guard let stored = KapePlatformSDKVPNType(rawValue: storedVPNType), all.contains(stored) else {
            return resolved(fromStored: storedVPNType)
        }
        return nil
    }
}
