//
//  PIACSIVPNStatusInformationProvider.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 07.08.26.
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
import PIACSI

// Mirrors the VPN section of the debug menu. The values are transient or live outside the
// `user_settings` whitelist, so nothing else in the report carries them.
struct PIACSIVPNStatusInformationProvider: CSIDataProvider {
    var sectionName: String { "vpn_status" }
    var content: String? { vpnStatusInformation() }

    let status: String
    let connectedVia: String
    let vpnType: String
    let obfuscation: String?
    let publicIP: String?
    let vpnIP: String?
    let redactIPs: Bool

    private static let unavailable = "---"

    private func vpnStatusInformation() -> String {
        let information = [
            "Status: \(status)",
            "Connected Via: \(connectedVia)",
            "Protocol: \(vpnType)",
            "Obfuscation: \(obfuscation ?? Self.unavailable)",
            "Public IP: \(publicIP ?? Self.unavailable)",
            "VPN IP: \(vpnIP ?? Self.unavailable)"
        ].joined(separator: "\n")

        return redactIPs ? information.redactIPs() : information
    }
}

extension PIACSIVPNStatusInformationProvider {
    init(connection: VPNConnectionInformation, redactIPs: Bool) {
        self.init(
            status: connection.status,
            connectedVia: connection.connectedVia,
            vpnType: Client.preferences.vpnType,
            obfuscation: PIATunnelSharedState.readStatus().activeConnection?.obfuscation,
            publicIP: Client.daemons.publicIP,
            vpnIP: Client.daemons.vpnIP,
            redactIPs: redactIPs
        )
    }
}
