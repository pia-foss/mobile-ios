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
    enum Filter: Equatable {
        case favorites
        case all
        // TODO: Check if title param is required
        case searchResults
        case recommended
        case previouslySearched
    }
    
    private let listUseCase: RegionsListUseCaseType
    private let favoriteUseCase: FavoriteRegionUseCaseType
    private let onServerSelectedRouterAction: AppRouter.Actions
    internal var filter: Filter
    private let previouslySearchedRegions: SearchedRegionsAvailabilityType
    
    @Published private(set) var servers: [ServerType] = []
    @Published private(set) var recommendedServers: [ServerType] = []
    @Published var search = ""
    @Published private(set) var favorites: [String] = []
    @Published var regionsListTitle: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    internal var favoriteToggleError: Error? = nil
    
    init(filter: Filter,
         listUseCase: RegionsListUseCaseType,
         favoriteUseCase: FavoriteRegionUseCaseType,
         onServerSelectedRouterAction: AppRouter.Actions,
         previouslySearchedRegions: SearchedRegionsAvailabilityType) {
        self.filter = filter
        self.listUseCase = listUseCase
        self.favoriteUseCase = favoriteUseCase
        self.onServerSelectedRouterAction = onServerSelectedRouterAction
        self.previouslySearchedRegions = previouslySearchedRegions
        refreshRegionsList()
        subscribeToSearchUpdates()
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
        favorites = favoriteUseCase.favoriteIdentifiers
        let allServers = listUseCase.getCurrentServers()
        
        switch filter {
        case .favorites:
            regionsListTitle = nil
            
            let favoriteServers = allServers.filter {
                favorites.contains($0.identifier)
            }
            
            servers = sortByName(favoriteServers)
            
        case .all:
            regionsListTitle = nil
            servers = sortByName(allServers)
        case .recommended:
            regionsListTitle = L10n.Localizable.Regions.Search.RecommendedLocations.title
            servers = Array(sortByLatency(allServers).prefix(20))
            
        case .searchResults:
            regionsListTitle = L10n.Localizable.Regions.Search.Results.title
            servers = filter(regions: allServers, with: search)
            if servers.isEmpty {
                // TODO: Show the Empty List Image View
            }
            
        case .previouslySearched:
            servers = mapPreviouslySearchedServers(with: allServers)

            // If there is no previous searches that match any of the current servers
            guard !servers.isEmpty else {
                // Then show recommended servers
                servers = sortByLatency(allServers)
                regionsListTitle = L10n.Localizable.Regions.Search.RecommendedLocations.title
                return
            }
            
            regionsListTitle = L10n.Localizable.Regions.Search.PreviousResults.title
            
        }
        
    }
    
}


// MARK: Search and Sort

extension RegionsListViewModel {
    func performSearch(with searchTerm: String) {
        search = searchTerm

        self.updateSearchFilterIfNeeded()
        self.refreshRegionsList()
        self.saveToPreviouslySearchedIfNeeded()
    }
    
    func filter(regions: [ServerType], with searchTerm: String) -> [ServerType] {

        let filteredServers = regions.filter({ server in
            return server.name.lowercased().contains(searchTerm.lowercased()) ||
            server.country.lowercased().contains(searchTerm.lowercased()) ||
            server.identifier.lowercased()
                .contains(searchTerm.lowercased()) ||
            server.regionIdentifier.lowercased()
                .contains(searchTerm.lowercased())
        })
        
        return filteredServers
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
        guard filter == .searchResults || filter == .recommended else { return }
        // If the search term is empty, then show the recommended locations
        if search.isEmpty {
            filter = .recommended
        } else {
            // else show the search results
            filter = .searchResults
        }
    }
    
    private func saveToPreviouslySearchedIfNeeded() {
        func belongToTheSameCountry(_ servers:[ServerType]) -> Bool {
            let countries = Set(servers.map { $0.country })
            return countries.count == 1
        }
        
        if servers.count <= 6 && belongToTheSameCountry(servers) {
            let newSearchedRegions = servers.map{ $0.identifier }
            let previousSearchedRegions = Array(previouslySearchedRegions.get().prefix(6))
            var previouslySearchedWithoutDuplicates = previousSearchedRegions.filter {
                !newSearchedRegions.contains($0)
            }
            
            var regionsToSave = Array(newSearchedRegions)
            regionsToSave.append(contentsOf: previouslySearchedWithoutDuplicates)

            previouslySearchedRegions.set(value: regionsToSave)

        }
    }
    
    private func mapPreviouslySearchedServers(with servers: [ServerType]) -> [ServerType] {
        let previousSearches = previouslySearchedRegions.get()
        
        return previousSearches.compactMap { prevSearch in
            return servers.first { server in
                server.identifier == prevSearch
            }
        }
    }
    
    private func sortByName(_ servers: [ServerType]) -> [ServerType] {
        servers.sorted(by: {
            $0.name < $1.name
        })
    }
    
    private func sortByLatency(_ servers: [ServerType]) -> [ServerType] {
       servers.sorted(by: {
            $0.pingTime ?? 0 < $1.pingTime ?? 0
        })
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
            // TODO: Localize
            return "Remove from Favorites"
        } else {
            return "Add to Favorites"
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
