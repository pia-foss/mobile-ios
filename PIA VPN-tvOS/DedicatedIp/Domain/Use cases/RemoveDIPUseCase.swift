//
//  RemoveDIPUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIADashboard
import PIALibrary

protocol RemoveDIPUseCaseType {
    func callAsFunction() async throws
}

private let log = PIALogger.logger(for: RemoveDIPUseCase.self)

final class RemoveDIPUseCase: RemoveDIPUseCaseType {
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
    
    func callAsFunction() async throws {
        guard let dedicatedIPServer = getDedicatedIP(),
        let dipToken = dedicatedIPServer.dipToken else {
            return
        }

        log.info("Removing DIP token")
        let selectedServer = selectedServer.selectedServer
        if selectedServer.dipToken == dedicatedIPServer.dipToken {
            log.info("DIP server was selected, disconnecting VPN from \(dedicatedIPServer)")
            try await vpnCpnnectionUseCase.disconnect()
        }

        try favoriteRegionsUseCase.removeFromFavorites(dedicatedIPServer.identifier, isDipServer: true)
        dedicatedIpProvider.removeDIPToken(dipToken)

        #if os(iOS)
        DispatchQueue.main.async { Macros.postNotification(.PIAServerHasBeenUpdated) }
        #endif
    }
}
