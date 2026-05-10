//
//  PIARegionStagingClientStateProvider.swift
//
//
//  Created by Said Rehouni on 26/3/24.
//

import Foundation
import regions

final class PIARegionStagingClientStateProvider: IRegionEndpointProvider {
    func regionEndpoints() -> [RegionEndpoint] {
        [
            RegionEndpoint(endpoint: Client.configuration.baseUrl, isProxy: false, usePinnedCertificate: false, certificateCommonName: nil)
        ]
    }
}
