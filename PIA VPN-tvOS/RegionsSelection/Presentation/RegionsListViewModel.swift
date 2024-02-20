//
//  RegionsListViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import Combine

class RegionsListViewModel: ObservableObject {

    private let listUseCase: RegionsListUseCaseType
    private let favoriteUseCase: FavoriteRegionUseCaseType
    private let regionsFilterUseCase: RegionsFilterUseCaseType
    private let regionsDisplayNameUseCase: RegionsDisplayNameUseCaseType
    private let optimalLocationUseCase: OptimalLocationUseCaseType
    
    private let onServerSelectedRouterAction: AppRouter.Actions
    internal var filter: RegionsListFilter
    
    @Published private(set) var servers: [ServerType] = []
    @Published private(set) var optimalAndDIPServers: [ServerType] = []
    @Published private(set) var optimalAndDIPServersSectionTitle: String? = nil
    @Published private(set) var recommendedServers: [ServerType] = []
    @Published var search = ""
    @Published private(set) var favorites: [String] = []
    @Published var regionsListTitle: String? = nil
    @Published var displayNameForOptimalLocation = (title: L10n.Localizable.LocationSelection.OptimalLocation.title, subtitle: L10n.Localizable.Global.automatic)
    
    private var cancellables = Set<AnyCancellable>()
    internal var favoriteToggleError: Error? = nil
    
    private var allServers: [ServerType] = []
    
    init(filter: RegionsListFilter,
         listUseCase: RegionsListUseCaseType,
         favoriteUseCase: FavoriteRegionUseCaseType,
         regionsFilterUseCase: RegionsFilterUseCaseType,
         regionsDisplayNameUseCase: RegionsDisplayNameUseCaseType,
         optimalLocationUseCase: OptimalLocationUseCaseType,
         onServerSelectedRouterAction: AppRouter.Actions) {
        self.filter = filter
        self.listUseCase = listUseCase
        self.favoriteUseCase = favoriteUseCase
        self.regionsFilterUseCase = regionsFilterUseCase
        self.regionsDisplayNameUseCase = regionsDisplayNameUseCase
        self.optimalLocationUseCase = optimalLocationUseCase
        self.onServerSelectedRouterAction = onServerSelectedRouterAction
       
        allServers = listUseCase.getCurrentServers()
        optimalAndDIPServers = getOptimalAndDIPServersIfNeeded()
        optimalAndDIPServersSectionTitle = getOptimalAndDIPServersSectionTitle()
        refreshRegionsList()
        subscribeToSearchUpdates()
        subscribeToOptimalLocationTargetServerIfNeeded()
    }
    
    func getIconImageName(for server: ServerType) -> (unfocused: String, focused: String) {
        if server.isAutomatic {
            return (unfocused: .smart_location_icon_name, focused: .smart_location_icon_highlighted_name)
        } else {
            let flagIconName = "flag-\(server.country.lowercased())"
            return (unfocused: flagIconName, focused: flagIconName)
        }
    }
    
    func getDisplayName(for server: ServerType) -> (title: String, subtitle: String) {
        if server.isAutomatic {
            return displayNameForOptimalLocation
        } else {
            return regionsDisplayNameUseCase.getDisplayName(for: server, amongst: allServers)
        }
        
    }
    
    
    func didSelectRegionServer(_ server: ServerType) {
        listUseCase.select(server: server)
        onServerSelectedRouterAction()
    }

    func viewDidAppear() {
        if filter == .previouslySearched {
            refreshRegionsList()
        }
    }
    
    private func refreshRegionsList() {
        servers = regionsFilterUseCase.getServers(with: filter)
        regionsListTitle = getRegionsListTitle(for: filter)
        
        switch filter {
        case .all:
            regionsListTitle = L10n.Localizable.Regions.List.AllLocations.title
        case .searchResults:
            if servers.isEmpty {
                // TODO: Show the Empty List Image View
            }
            
        case .previouslySearched:
            // Show recommended servers if there are no previous searches registered
            if servers.isEmpty {
                servers = regionsFilterUseCase.getServers(with: .recommended)
                regionsListTitle = getRegionsListTitle(for: .recommended)
            }
            
        default:
            break
            
        }
        
    }
    
    private func getRegionsListTitle(for filter: RegionsListFilter) -> String? {
        switch filter {
        case .recommended:
            return L10n.Localizable.Regions.Search.RecommendedLocations.title
        case .searchResults(_):
            return L10n.Localizable.Regions.Search.Results.title
        case .previouslySearched:
            return L10n.Localizable.Regions.Search.PreviousResults.title
        default:
            return nil
        }
    }
    
}


// MARK: Search

extension RegionsListViewModel {
    func performSearch(with searchTerm: String) {
        search = searchTerm
        
        self.updateSearchFilterIfNeeded()
        self.refreshRegionsList()
        self.saveToPreviouslySearched()
    }
    
    private func subscribeToSearchUpdates() {
        $search
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchTerm in
                guard let self = self else { return }
                self.performSearch(with: searchTerm)
            }.store(in: &cancellables)
    }
    
    private func updateSearchFilterIfNeeded() {
        guard filter.isSearchResultsWithAnySearchTerm || filter == .recommended else { return }
        
        // If the search term is empty, then show the recommended locations
        if search.isEmpty {
            filter = .recommended
        } else {
            // else show the search results
            filter = .searchResults(search)
        }
    }
    
    private func saveToPreviouslySearched() {
        regionsFilterUseCase.saveToPreviouslySearched(servers: servers)
    }
}


// MARK: Favourites

extension RegionsListViewModel {
    func favoriteIconName(for server: ServerType) -> String {
        if isFavorite(server: server) {
            return "favorite-filled-icon"
        } else {
            return "favorite-stroke-icon"
        }
    }
    
    func favoriteContextMenuTitle(for server: ServerType) -> String {
        if isFavorite(server: server) {
            return L10n.Localizable.Regions.ContextMenu.Favorites.Remove.text
        } else {
            return L10n.Localizable.Regions.ContextMenu.Favorites.Add.text
        }
    }
    
    func toggleFavorite(server: ServerType) {
        if isFavorite(server: server) {
            removeFromFavorites(server)
        } else {
            addToFavorites(server)
        }
    }
    
    private func isFavorite(server: ServerType) -> Bool {
        let favoritesIds = favoriteUseCase.favoriteIdentifiers
        return favoritesIds.contains(server.identifier)
    }
    
    private func addToFavorites(_ server: ServerType) {
        favoriteToggleError = nil
        do {
            try  favoriteUseCase.addToFavorites(server.identifier)
            refreshRegionsList()
            favoriteToggleError = nil
        } catch {
            favoriteToggleError = error
        }
    }
    
    private func removeFromFavorites(_ server: ServerType) {
        favoriteToggleError = nil
        do {
            try  favoriteUseCase.removeFromFavorites(server.identifier)
            refreshRegionsList()
            favoriteToggleError = nil
        } catch {
            favoriteToggleError = error
        }
    }
    
}

// MARK: - Optimal Location and DIP Server

extension RegionsListViewModel {
    func getOptimalAndDIPServersIfNeeded() -> [ServerType] {
        // We only show the Optimal Location and DIP server if the list is 'All' servers
        guard filter == .all else { return [] }
        
        var servers: [ServerType] = []
        let optimalLocation = Server.automatic
        servers.append(optimalLocation)
        // TODO: Retrieve the DIP server and append it to the list of servers after the optimal one
        return servers
    }
    
    func getOptimalAndDIPServersSectionTitle() -> String? {
        // We only show the Optimal Location and DIP server if the list is 'All' servers
        guard filter == .all else { return nil }
        
        // TODO: If the user has also a DIP server, then use the `L10n.Localizable.Regions.List.OptimalLocationWithDipLocation.title` instead
        return L10n.Localizable.Regions.List.OptimalLocation.title
        
    }
    
    func subscribeToOptimalLocationTargetServerIfNeeded() {
        
        guard filter == .all || filter == .favorites else { return }
        
        optimalLocationUseCase.getTargetLocaionForOptimalLocation()
            .sink { [weak self] newTargetLocation in
                guard let self else { return }
                self.displayNameForOptimalLocation = self.regionsDisplayNameUseCase.getDisplayNameForOptimalLocation(with: newTargetLocation)
            }.store(in: &cancellables)
        
    }
    
    
}
