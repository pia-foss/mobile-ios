//
//  RemoveDIPUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol RemoveDIPUseCaseType {
    func callAsFunction()
}

class RemoveDIPUseCase: RemoveDIPUseCaseType {
    private let dedicatedIpProvider: DedicatedIPProviderType
    private let favoriteRegionsUseCase: FavoriteRegionUseCaseType
    private let getDedicatedIP: GetDedicatedIpUseCaseType
    private let vpnCpnnectionUseCase: VpnConnectionUseCaseType
    private let selectedServer: ClientPreferencesType
    
    init(dedicatedIpProvider: DedicatedIPProviderType, favoriteRegionsUseCase: FavoriteRegionUseCaseType, getDedicatedIP: GetDedicatedIpUseCaseType, vpnCpnnectionUseCase: VpnConnectionUseCaseType, selectedServer: ClientPreferencesType) {
        self.dedicatedIpProvider = dedicatedIpProvider
        self.favoriteRegionsUseCase = favoriteRegionsUseCase
        self.getDedicatedIP = getDedicatedIP
        self.vpnCpnnectionUseCase = vpnCpnnectionUseCase
        self.selectedServer = selectedServer
    }
    
    func callAsFunction() {
        guard let dedicatedIPServer = getDedicatedIP(),
        let dipToken = dedicatedIPServer.dipToken else {
            return
        }
        
        dedicatedIpProvider.removeDIPToken(dipToken)
        _ = try? favoriteRegionsUseCase.removeFromFavorites(dedicatedIPServer.identifier, isDipServer: true)
        
        let selectedServer = selectedServer.selectedServer
        if selectedServer.identifier == dedicatedIPServer.identifier {
            Task {
                try? await vpnCpnnectionUseCase.disconnect()
            }
        }
    }
}
