//
//  RegionsFilterUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum RegionsListFilter: Equatable, Hashable {
    case all
    case favorites
    case recommended
    case searchResults(String)
    case previouslySearched
    
    var isSearchResultsWithAnySearchTerm: Bool {
        switch self {
        case .searchResults(_):
            return true
        default:
            return false
        }
    }
    
    static func ==(lhs: RegionsListFilter, rhs: RegionsListFilter) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case (.favorites, .favorites):
            return true
        case (.searchResults(let lhsSearch), .searchResults(let rhsSearch)):
            return lhsSearch == rhsSearch
        case (.recommended, .recommended):
            return true
        case (.previouslySearched, .previouslySearched):
            return true
        default:
            return false
        }
    }
}

enum SortingOrder {
    case ascending, descending
}

protocol RegionsFilterUseCaseType {
    func getServers(with filter: RegionsListFilter) -> [ServerType]
    func saveToPreviouslySearched(servers: [ServerType])
}

class RegionsFilterUseCase: RegionsFilterUseCaseType {
    private let maxReccommendedServersCount = 12
    private let serversUseCase: RegionsListUseCaseType
    private let favoritesUseCase: FavoriteRegionUseCaseType
    private let previouslySearchedAvailability: SearchedRegionsAvailabilityType
    private let getDedicatedIpUseCase: GetDedicatedIpUseCaseType
    internal let maxPreviouslySearchedCount = 8
    
    init(serversUseCase: RegionsListUseCaseType, favoritesUseCase: FavoriteRegionUseCaseType, searchedRegionsAvailability: SearchedRegionsAvailabilityType, getDedicatedIpUseCase: GetDedicatedIpUseCaseType) {
        self.serversUseCase = serversUseCase
        self.favoritesUseCase = favoritesUseCase
        self.previouslySearchedAvailability = searchedRegionsAvailability
        self.getDedicatedIpUseCase = getDedicatedIpUseCase
    }
    
    func getServers(with filter: RegionsListFilter) -> [ServerType] {
        return getServers(with: filter, sorting: .ascending)
    }
    
    func saveToPreviouslySearched(servers: [ServerType]) {
        func belongToTheSameCountry(_ servers:[ServerType]) -> Bool {
            let countries = Set(servers.map { $0.country })
            return countries.count == 1
        }
        
        if servers.count <= maxPreviouslySearchedCount && belongToTheSameCountry(servers) {
            
            let newSearchedRegions = servers.map{ $0.identifier }
            let previousSearchedRegions = Array(previouslySearchedAvailability.get().prefix(maxPreviouslySearchedCount))
            
            let previouslySearchedWithoutDuplicates = previousSearchedRegions.filter {
                !newSearchedRegions.contains($0)
            }
            
            var regionsToSave = Array(newSearchedRegions)
            regionsToSave.append(contentsOf: previouslySearchedWithoutDuplicates)

            previouslySearchedAvailability.set(value: regionsToSave)

        }
    }
    
}


// MARK: - Private

extension RegionsFilterUseCase {
    private func getServers(with filter: RegionsListFilter, sorting: SortingOrder) -> [ServerType] {
        let allServers = serversUseCase.getCurrentServers()
        
        switch filter {
        case .all:
            let serversWithoutDip = getServersWithoutDip(from: allServers)
            return sortedAlphabeticallyByName(serversWithoutDip, with: sorting)
            
        case .favorites:
            let favorites = getFavorites(from: allServers)
            return sortedAlphabeticallyByName(favorites, with: sorting)
            
        case .recommended:
            return getRecommended(from: allServers)
            
        case .searchResults(let searchTerm):
            let results = getSearchResultsFrom(allServers, with: searchTerm)
            return sortedAlphabeticallyByName(results, with: sorting)
            
        case .previouslySearched:
            return getPreviouslySearchedRegions(from: allServers)
        }
        
    }
    
    private func getServersWithoutDip(from servers: [ServerType]) -> [ServerType] {
        return servers.filter { self.getDedicatedIpUseCase.isDedicatedIp($0) == false }
    }
    
    private func getFavorites(from servers: [ServerType]) -> [ServerType] {
        let autoServer = SelectedServerUseCase.automaticServer()
        let favoritesIds = favoritesUseCase.favoriteIdentifiers
        
        var favoriteServers = servers.filter {
            favoritesIds.contains($0.identifier) &&
            $0.dipToken == nil
        }
        
        if favoritesIds.contains(autoServer.identifier) {
            favoriteServers.append(autoServer)
        }
        
        if let favoriteDipServerId = favoritesUseCase.getFavoriteDIPServerId(),
           let favoriteDipServer = (
            servers.filter {
                $0.dipToken != nil &&
                $0.identifier == favoriteDipServerId
            }
           ).first
        {

            favoriteServers.append(favoriteDipServer)
            
        }

        return favoriteServers
    }
    
    private func getRecommended(from servers: [ServerType]) -> [ServerType] {
        Array(servers.sorted(by: {
             $0.pingTime ?? 0 < $1.pingTime ?? 0
        }).prefix(maxReccommendedServersCount))
    }
    
    private func getSearchResultsFrom(_ servers: [ServerType], with searchTerm: String) -> [ServerType] {
        
        let filteredServers = servers.filter({ server in
            return server.name.lowercased().contains(searchTerm.lowercased()) ||
            server.country.lowercased().contains(searchTerm.lowercased()) ||
            server.identifier.lowercased()
                .contains(searchTerm.lowercased()) ||
            server.regionIdentifier.lowercased()
                .contains(searchTerm.lowercased())
        })
        
        return filteredServers
    }
    
    private func getPreviouslySearchedRegions(from servers: [ServerType]) -> [ServerType] {
        let previousSearches = previouslySearchedAvailability.get()
        
        return previousSearches.compactMap { prevSearch in
            return servers.first { server in
                server.identifier == prevSearch
            }
        }
    }
    
    private func sortedAlphabeticallyByName(_ servers: [ServerType], with order: SortingOrder) -> [ServerType] {
        switch order {
        case .ascending:
            servers.sorted(by: {
                $0.name < $1.name
            })
        case .descending:
            servers.sorted(by: {
                $0.name > $1.name
            })
        }
    }
}
