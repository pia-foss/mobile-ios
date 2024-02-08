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
    
    private let serversUseCase: RegionsListUseCaseType
    private let favoritesUseCase: FavoriteRegionUseCaseType
    private let previouslySearchedAvailability: SearchedRegionsAvailabilityType
    internal let maxPreviouslySearchedCount = 8
    
    init(serversUseCase: RegionsListUseCaseType, favoritesUseCase: FavoriteRegionUseCaseType, searchedRegionsAvailability: SearchedRegionsAvailabilityType) {
        self.serversUseCase = serversUseCase
        self.favoritesUseCase = favoritesUseCase
        self.previouslySearchedAvailability = searchedRegionsAvailability
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
            return sortedAlphabeticallyByName(allServers, with: sorting)
            
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
    private func getFavorites(from servers: [ServerType]) -> [ServerType] {
        let favoritesIds = favoritesUseCase.favoriteIdentifiers
        
        return servers.filter {
            favoritesIds.contains($0.identifier)
        }
    }
    
    private func getRecommended(from servers: [ServerType]) -> [ServerType] {
        servers.sorted(by: {
             $0.pingTime ?? 0 < $1.pingTime ?? 0
         })
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