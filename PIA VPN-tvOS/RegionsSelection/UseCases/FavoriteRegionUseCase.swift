//
//  FavoriteRegionUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol FavoriteRegionUseCaseType {
    var favoriteIdentifiers: [String] { get }
    @discardableResult
    func addToFavorites(_ id: String) throws -> [String]
    @discardableResult
    func removeFromFavorites(_ id: String) throws -> [String]
}

class FavoriteRegionUseCase: FavoriteRegionUseCaseType {
    
    private let keychain: KeychainType
    
    init(keychain: KeychainType) {
        self.keychain = keychain
    }
    
    var favoriteIdentifiers: [String] {
        if let favorites = try? keychain.getFavorites() {
            return favorites
        }
        
        return []
    }
    
    @discardableResult
    func addToFavorites(_ id: String) throws -> [String] {
        var newFavorites = favoriteIdentifiers
        newFavorites.append(id)
        try keychain.set(favorites: newFavorites)
        return newFavorites
    }
    
    @discardableResult
    func removeFromFavorites(_ id: String) throws -> [String] {
        var newFavorites = favoriteIdentifiers.filter { id != $0 }
        try keychain.set(favorites: newFavorites)
        return newFavorites
    }
    
    
}
