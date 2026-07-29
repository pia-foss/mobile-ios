//
//  HardcodedTestServers.swift
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

enum HardcodedTestServers {

    private static let slug = "dco-test-12416"
    private static let name = "DCO Test 12416 (138.199.31.184)"
    private static let ip = "138.199.31.184"
    private static let commonName = "Server-12416-1a"

    static func register() {
        let address = Server.ServerAddressIP(ip: ip, cn: commonName, van: true)

        let server = Server(
            serial: "",
            name: name,
            country: "universal",
            hostname: "\(slug).invalid",
            openVPNAddressesForTCP: [address],
            openVPNAddressesForUDP: [address],
            wireGuardAddressesForUDP: [address],
            iKEv2AddressesForUDP: [address],
            pingAddress: nil,
            regionIdentifier: slug
        )

        Client.configuration.addCustomServer(server)
    }
}
