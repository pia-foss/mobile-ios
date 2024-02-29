//
//  FavoriteRegionUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
@testable import PIA_VPN_tvOS

class FavoriteRegionUseCaseMock: FavoriteRegionUseCaseType {
    
    var favoriteIdentifiers: [String] = []
    @Published private var favorites: [String] = []
    var favoriteIdentifiersPublisher: Published<[String]>.Publisher {
        $favorites
    }
    
    var addToFavoritesCalled = false
    var addToFavoritesCalledAttempt = 0
    var addToFavoritesCalledWithArguments: (serverId: String, isDipServer: Bool) = (serverId: "", isDipServer: false)
    var addToFavoritesCalledErrorThrown: Error?
    func addToFavorites(_ id: String, isDipServer: Bool) throws -> [String] {
        addToFavoritesCalled = true
        addToFavoritesCalledAttempt += 1
        addToFavoritesCalledWithArguments = (serverId: id, isDipServer: isDipServer)
        if let error = addToFavoritesCalledErrorThrown {
            throw error
        } else {
            return favoriteIdentifiers
        }
    }
    
    var removeFromFavoritesCalled = false
    var removeFromFavoritesCalledAttempt = 0
    var removeFromFavoritesCalledWithArguments: (serverId: String, isDipServer: Bool) = (serverId: "", isDipServer: false)
    var removeFromFavoritesCalledErrorThrown: Error?
    func removeFromFavorites(_ id: String, isDipServer: Bool) throws -> [String] {
        removeFromFavoritesCalled = true
        removeFromFavoritesCalledAttempt += 1
        removeFromFavoritesCalledWithArguments = (serverId: id, isDipServer: isDipServer)
        
        if let error = removeFromFavoritesCalledErrorThrown {
            throw error
        } else {
            return favoriteIdentifiers
        }
    }
    
    
    var getFavoriteDIPServerIdCalled = false
    var getFavoriteDIPServerIdCalledAttempt = 0
    var getFavoriteDIPServerIdResult: String?
    func getFavoriteDIPServerId() -> String? {
        getFavoriteDIPServerIdCalled = true
        getFavoriteDIPServerIdCalledAttempt += 1
        return getFavoriteDIPServerIdResult
    }
    
    var isFavoriteServerWithCalled = false
    var isFavoriteServerWithCalledAttepmt = 0
    var isFavoriteServerWithArguments: (identifier: String, isDipServer: Bool)!
    var isFavoriteServerWithIdentifierResult: Bool = false
    func isFavoriteServerWith(identifier: String, isDipServer: Bool) -> Bool {
        isFavoriteServerWithCalled = true
        isFavoriteServerWithCalledAttepmt += 1
        isFavoriteServerWithArguments = (identifier: identifier, isDipServer: isDipServer)
        return isFavoriteServerWithIdentifierResult
    }
    
}
