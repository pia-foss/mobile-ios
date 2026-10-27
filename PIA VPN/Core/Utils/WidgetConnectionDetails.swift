//
//  WidgetConnectionDetails.swift
//  PIA VPN
//
//  Created by Mario on 27/10/26.
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

import PIALibrary

/// The protocol, port and socket rows of the medium widget.
struct WidgetConnectionDetails: Equatable {
    let vpnProtocol: String
    let port: String
    let socket: String
}

extension WidgetConnectionDetails {

    /// Prefers what the tunnel resolved over the selection, which says nothing under Automatic.
    init(selectedVPNType: String, actualConnection: ActualConnection?) {
        let resolvedVPNType = actualConnection?.vpnType?.rawValue
        let vpnType = resolvedVPNType ?? selectedVPNType
        vpnProtocol = selectedVPNType.vpnProtocol(resolvedAs: resolvedVPNType)
        port = (actualConnection?.port).flatMap(String.init) ?? vpnType.port
        socket = actualConnection?.transport.rawValue.uppercased() ?? vpnType.socket
    }

    static var current: WidgetConnectionDetails {
        WidgetConnectionDetails(
            selectedVPNType: Client.preferences.vpnType,
            actualConnection: Client.providers.vpnProvider.actualConnection
        )
    }

    /// Returns whether any stored value changed.
    @discardableResult
    func save(to preferences: AppPreferences = .shared) -> Bool {
        let changed =
            preferences.todayWidgetVpnProtocol != vpnProtocol
            || preferences.todayWidgetVpnPort != port
            || preferences.todayWidgetVpnSocket != socket
        preferences.todayWidgetVpnProtocol = vpnProtocol
        preferences.todayWidgetVpnPort = port
        preferences.todayWidgetVpnSocket = socket
        return changed
    }
}
