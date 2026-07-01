//
//  KapePlatformSDKVPNType.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 09.06.26.
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

/// The persisted VPN-type identifiers the PlatformSDK tunnel reads from preferences and the
/// custom-configuration maps (`Client.preferences.vpnType`, `vpnCustomConfigurationMaps`).
///
/// These string values are the legacy identifiers ("PIA" for OpenVPN, "PIAWG" for WireGuard).
/// They are duplicated here on purpose so the PlatformSDK code does not reference the legacy
/// `PIATunnelProfile` / `PIAWGTunnelProfile` types (which are being removed); centralising them
/// keeps the raw strings out of the call sites.
public enum KapePlatformSDKVPNType: String {
    /// Persisted identifier for the OpenVPN profile.
    case openVPN = "PIA"

    /// Persisted identifier for the WireGuard profile.
    case wireGuard = "PIAWG"

    /// Persisted identifier for automatic protocol selection (the tunnel tries WireGuard first,
    /// then falls back to OpenVPN).
    case automatic = "PIAAutomatic"

    /// Legacy IKEv2 identifier. The PlatformSDK tunnel cannot run IKEv2, so this exists only to
    /// recognise the value left in `Client.preferences.vpnType` by pre-PlatformSDK installs — e.g.
    /// to migrate such users onto a supported protocol. It is never a connectable selection here.
    case iKEv2 = "IKEv2"
}

public extension KapePlatformSDKVPNType {
    var displayName: String {
        switch self {
        case .wireGuard:
            return "WireGuard®"
        case .openVPN:
            return "OpenVPN"
        case .iKEv2:
            return "IPSec (IKEv2)"
        case .automatic:
            // TODO: [PlatformSDK] Localize string
            return "Automatic"
        }
    }
}
