//
//  DedicatedIPFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

public enum DedicatedIPFactory {
    #if os(tvOS)
    static func makeDedicatedIPView() -> DedicatedIPView {
        DedicatedIPView(viewModel: makeDedicatedIPViewModel())
    }
    
    private static func makeDedicatedIPViewModel() -> DedicatedIPViewModel {
        DedicatedIPViewModel(getDedicatedIp: makeGetDedicatedIpUseCase(), 
                             activateDIPToken: makeActivateDIPTokenUseCase(),
                             removeDIPToken: makeRemoveDIPUseCase())
    }
    #endif
    
    static func makeGetDedicatedIpUseCase() -> GetDedicatedIpUseCaseType {
        GetDedicatedIpUseCase(serverProvider: makeDefaultServerProvider(),
                              dedicatedIpProvider: makeDedicatedIPProvider())
    }
    
    static func makeActivateDIPTokenUseCase() -> ActivateDIPTokenUseCaseType {
        ActivateDIPTokenUseCase(dipServerProvider: makeDedicatedIPProvider())
    }
    
    static func makeRemoveDIPUseCase() -> RemoveDIPUseCaseType {
        RemoveDIPUseCase(dedicatedIpProvider: makeDedicatedIPProvider(),
                         favoriteRegionsUseCase: RegionsSelectionFactory.makeFavoriteRegionUseCase,
                         getDedicatedIP: makeGetDedicatedIpUseCase(), 
                         vpnConnectionUseCase: VpnConnectionFactory.makeVpnConnectionUseCase,
                         selectedServer: RegionsSelectionFactory.makeClientPreferences)
    }
    
    private static func makeDedicatedIPProvider() -> DedicatedIPProviderType {
        DedicatedIPProvider(serverProvider: makeDefaultServerProvider())
    }
    
    private static func makeDefaultServerProvider() -> DefaultServerProvider {
        guard let defaultServerProvider = Client.providers.serverProvider as? DefaultServerProvider else {
            fatalError("Incorrect server provider type")
        }
        
        return defaultServerProvider
    }
}
