//
//  PIARegionStagingClientStateProvider.swift
//
//
//  Created by Said Rehouni on 26/3/24.
//

import Foundation
import regions

@available(tvOS 17.0, *)
class PIARegionStagingClientStateProvider: IRegionEndpointProvider {
    func regionEndpoints() -> [RegionEndpoint] {
        [
            RegionEndpoint(endpoint: Client.configuration.baseUrl, isProxy: false, usePinnedCertificate: false, certificateCommonName: nil)
        ]
    }
}
