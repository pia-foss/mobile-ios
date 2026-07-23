//
//  NEVPNStatus+DescriptionForLog.swift
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

import NetworkExtension

extension NEVPNStatus {
    /// Log-only, human-readable description for `NEVPNStatus`. The module-wide
    /// `NEVPNStatus.descriptionForLog` extension was removed from PIALibrary; this scoped copy
    /// keeps the PlatformSDK connect log readable without reintroducing a shared extension.
    var descriptionForLog: String {
        switch self {
        case .invalid: return "invalid"
        case .disconnected: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .reasserting: return "reasserting"
        case .disconnecting: return "disconnecting"
        @unknown default: return "unknown(\(rawValue))"
        }
    }
}
