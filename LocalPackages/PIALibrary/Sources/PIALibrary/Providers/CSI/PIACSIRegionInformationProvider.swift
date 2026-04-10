//
//  PIACSIRegionInformationProvider.swift
//  PIALibrary
//
//  Created by Juan Docal on 9/12/20.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import PIACSI

struct PIACSIRegionInformationProvider: CSIDataProvider {
    var sectionName: String { "regions.json" }
    var content: String? { regionInformation() }
    let redactIPs: Bool

    private func regionInformation() -> String {
        var redactedServers: [String] = []

        for server in Client.providers.serverProvider.currentServers {
            let redactedServer = Server(
                serial: server.serial,
                name: server.name,
                country: server.country,
                hostname: "REDACTED",
                openVPNAddressesForTCP: nil,
                openVPNAddressesForUDP: nil,
                wireGuardAddressesForUDP: nil,
                iKEv2AddressesForUDP: nil,
                pingAddress: nil,
                responseTime: nil,
                geo: server.geo,
                offline: server.offline,
                latitude: server.latitude,
                longitude: server.longitude,
                meta: nil,
                dipExpire: nil,
                dipToken: nil,
                dipStatus: nil,
                dipUsername: nil,
                regionIdentifier: server.regionIdentifier
            )
            if let data = try? JSONEncoder().encode(redactedServer),
               let description = String(data: data, encoding: .utf8) {
                redactedServers.append(description)
            }
        }

        return redactIPs ? redactedServers.debugDescription.redactIPs() : redactedServers.debugDescription
    }
}
