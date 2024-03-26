//
//  NetworkFactory.swift
//  PIA VPN
//
//  Created by Laura S on 3/25/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class NetworkFactory {
    static func makeVPNServerStatusUseCase() -> VPNServerStatusUseCaseType {
        VPNServerStatusUseCase()
    }
}
