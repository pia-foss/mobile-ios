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
    

    static func makeRegionsListViewModel(with filter: RegionsListViewModel.Filter) -> RegionsListViewModel {
        return RegionsListViewModel(filter: filter, listUseCase: makeRegionsListUseCase(),
                                    favoriteUseCase: makeFavoriteRegionUseCase(),
                                    onServerSelectedRouterAction: .goBackToRoot(router: AppRouterFactory.makeAppRouter()), previouslySearchedRegions: makeSearchedRegionsAvailability())
    }
    
    static func makeSearchedRegionsAvailability() -> SearchedRegionsAvailabilityType {
        return SearchedRegionsAvailability(userDefaults: UserDefaults.standard)
    }
    
    static func makeAllRegionsListView() -> RegionsListView {
        return RegionsListView(viewModel: makeRegionsListViewModel(with: .all))
    }
    
    static func makeFavoriteRegionsListView() -> RegionsListView {
        return RegionsListView(viewModel: makeRegionsListViewModel(with: .favorites))
    }
    
    static func makeSearchRegionsListView() -> RegionsListView {
        return RegionsListView(viewModel: makeRegionsListViewModel(with: .searchResults))
    }
    
    static func makeRecommendedRegionsListView() -> RegionsListView {
        return RegionsListView(viewModel: makeRegionsListViewModel(with: .recommended))
    }
    
    static func makePreviouslySearchedRegionsListView() -> RegionsListView {
        return RegionsListView(viewModel: makeRegionsListViewModel(with: .previouslySearched))
    }
    
    
    static func makeRegionsListUseCase() -> RegionsListUseCaseType {
        return RegionsListUseCase(serverProvider: DashboardFactory.makeServerProvider(), clientPreferences: Client.preferences)
    }
    
    static func makeFavoriteRegionUseCase() -> FavoriteRegionUseCaseType {
        return FavoriteRegionUseCase(keychain: KeychainFactory.makeKeychain())
    }
    
}
