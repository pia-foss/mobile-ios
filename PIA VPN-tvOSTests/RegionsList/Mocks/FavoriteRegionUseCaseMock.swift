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
    var addToFavoritesCalledWithArgument: String = ""
    var addToFavoritesCalledErrorThrown: Error?
    func addToFavorites(_ id: String) throws -> [String] {
        addToFavoritesCalled = true
        addToFavoritesCalledAttempt += 1
        addToFavoritesCalledWithArgument = id
        if let error = addToFavoritesCalledErrorThrown {
            throw error
        } else {
            return favoriteIdentifiers
        }
    }
    
    var removeFromFavoritesCalled = false
    var removeFromFavoritesCalledAttempt = 0
    var removeFromFavoritesCalledWithArgument = ""
    var removeFromFavoritesCalledErrorThrown: Error?
    func removeFromFavorites(_ id: String) throws -> [String] {
        removeFromFavoritesCalled = true
        removeFromFavoritesCalledAttempt += 1
        removeFromFavoritesCalledWithArgument = id
        
        if let error = removeFromFavoritesCalledErrorThrown {
            throw error
        } else {
            return favoriteIdentifiers
        }
    }
    
    
}
