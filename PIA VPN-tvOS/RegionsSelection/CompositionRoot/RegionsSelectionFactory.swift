//
//  RegionsSelectionFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class RegionsSelectionFactory {
    
    static func makeRegionsContainerView() -> RegionsContainerView {
        return RegionsContainerView(viewModel: makeRegionsContainerViewModel())
    }
    
    static func makeRegionsContainerViewModel() -> RegionsContainerViewModel {
        return RegionsContainerViewModel(onSearchSelectedAction: .navigate(router: AppRouterFactory.makeAppRouter(), destination: RegionSelectionDestinations.search))
    }
    
    static func makeRegionsListViewModel() -> RegionsListViewModel {
        return RegionsListViewModel(useCase: makeRegionsListUseCase(), onServerSelectedRouterAction: .goBackToRoot(router: AppRouterFactory.makeAppRouter()))
    }
    
    static func makeRegionsListView() -> RegionsListView {
        return RegionsListView(viewModel: makeRegionsListViewModel())
    }
    
    static func makeRegionsListUseCase() -> RegionsListUseCaseType {
        return RegionsListUseCase(serverProvider: DashboardFactory.makeServerProvider(), clientPreferences: Client.preferences)
    }
}
