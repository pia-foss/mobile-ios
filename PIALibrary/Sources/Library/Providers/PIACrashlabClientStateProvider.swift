//
//  PIACrashlabClientStateProvider.swift
//  PIALibrary
//
//  Created by Juan Docal on 9/12/20.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import PIACrashlab

class PIACrashlabClientStateProvider : CrashlabClientStateProvider {

    func crashlabEndpoints() -> [CrashlabEndpoint] {
        let validEndpoints = EndpointManager.shared.availableCrashlabEndpoints()
        var clientEndpoints = [CrashlabEndpoint]()
        for endpoint in validEndpoints.reversed() {
            clientEndpoints.append(
                CrashlabEndpoint(
                    endpoint: endpoint.host,
                    isProxy: endpoint.isProxy,
                    usePinnedCertificate: endpoint.useCertificatePinning,
                    certificateCommonName: endpoint.commonName
                )
            )
        }
        return clientEndpoints
    }
}
