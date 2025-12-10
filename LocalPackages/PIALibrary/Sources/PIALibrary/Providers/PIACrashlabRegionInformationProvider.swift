//
//  PIACSIRegionInformationProvider.swift
//  PIALibrary
//
//  Created by Juan Docal on 9/12/20.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import csi

@available(tvOS 17.0, *)
class PIACSIRegionInformationProvider : ICSIProvider {
    
    var filename: String? { return "regions_information" }
    
    var isPersistedData: Bool { return true }
    
    var providerType: ProviderType { return ProviderType.regionInformation }
    
    var reportType: ReportType { return ReportType.diagnostic }
    
    var value: String? { return regionInformation() }
    

    func regionInformation() -> String {
        var redactedServers: [String] = []
        for server in Client.providers.serverProvider.currentServers {
            if let redactedServer = Server(
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
            ).toJSON()?.description {
                redactedServers.append(redactedServer)
            }
        }
        return redactedServers.debugDescription.redactIPs()
    }
}
