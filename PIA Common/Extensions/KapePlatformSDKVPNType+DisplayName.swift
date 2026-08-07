//
//  KapePlatformSDKVPNType+DisplayName.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIALocalizations

extension KapePlatformSDKVPNType {
    /// User-facing name for the VPN type, shown in the protocol-selection UI.
    ///
    /// Lives in the app layer (shared by the iOS and tvOS targets via `PIA Common`) rather than in
    /// `PIALibrary` so it can resolve localized strings through `PIALocalizations`, which the core
    /// package does not depend on.
    var displayName: String {
        switch self {
        case .wireGuard:
            return "WireGuard®"
        case .openVPN:
            return "OpenVPN"
        case .iKEv2:
            return "IPSec (IKEv2)"
        case .automatic:
            return L10n.Global.automatic
        }
    }
}
