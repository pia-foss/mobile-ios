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
    func callAsFunction() async -> Result<Void, DedicatedIPError>
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
    
    func callAsFunction() async -> Result<Void, DedicatedIPError> {
        guard let dedicatedIPServer = getDedicatedIP(),
        let dipToken = dedicatedIPServer.dipToken else {
            return .success(())
        }

        let selectedServer = selectedServer.selectedServer
        if selectedServer.dipToken == dedicatedIPServer.dipToken {
            log.debug("Disconnecting from dedicated IP server \(dedicatedIPServer)")
            do {
                try await vpnCpnnectionUseCase.disconnect()
            } catch {
                return .failure(.generic(error))
            }
        }

        do {
            try favoriteRegionsUseCase.removeFromFavorites(dedicatedIPServer.identifier, isDipServer: true)
        } catch {
            return .failure(.generic(error))
        }
        dedicatedIpProvider.removeDIPToken(dipToken)

        #if os(iOS)
        DispatchQueue.main.async { Macros.postNotification(.PIAServerHasBeenUpdated) }
        #endif

        return .success(())
    }
}
