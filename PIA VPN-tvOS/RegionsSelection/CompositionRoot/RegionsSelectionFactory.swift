//
//  RegionsSelectionFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import SwiftUI

class RegionsSelectionFactory {
    
    static func makeRegionsContainerView() -> RegionsContainerView {
        return RegionsContainerView(viewModel: makeRegionsContainerViewModel())
    }
    
    static func makeRegionsContainerViewModel() -> RegionsContainerViewModel {
        return RegionsContainerViewModel(favoritesUseCase: makeFavoriteRegionUseCase, onSearchSelectedAction: .navigate(router: AppRouterFactory.makeAppRouter(), destination: RegionsDestinations.search))
    }
    

    static func makeRegionsListViewModel(with filter: RegionsListFilter) -> RegionsListViewModel {
        return RegionsListViewModel(filter: filter, listUseCase: makeRegionsListUseCase(),
                                    favoriteUseCase: makeFavoriteRegionUseCase, regionsFilterUseCase: makeRegionsFilterUseCase(), regionsDisplayNameUseCase: RegionsDisplayNameUseCase(),
                                    onServerSelectedRouterAction: .goBackToRoot(router: AppRouterFactory.makeAppRouter()))
    }
    
    static func makeRegionsFilterUseCase() -> RegionsFilterUseCaseType {
        return RegionsFilterUseCase(serversUseCase: makeRegionsListUseCase(), favoritesUseCase: makeFavoriteRegionUseCase, searchedRegionsAvailability: makeSearchedRegionsAvailability())
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
    
    static func makeSearchRegionsListView() -> some View {
        let viewModel = makeRegionsListViewModel(with: .searchResults(""))
        let searchableRegions = RegionsListView(viewModel: viewModel)
        
        return searchableRegions.searchable(text: searchableRegions.$viewModel.search, prompt:  L10n.Localizable.Regions.Search.InputField.placeholder)
            
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
    
    /// FavoritesUseCase is the same instance across the whole app
    /// in order to be able to publish updates to the favorites collection
    static var makeFavoriteRegionUseCase: FavoriteRegionUseCaseType = {
        return FavoriteRegionUseCase(keychain: KeychainFactory.makeKeychain())
    }()
    
}
