//
//  FavoriteRegionUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine

protocol FavoriteRegionUseCaseType {
    var favoriteIdentifiers: [String] { get }
    var favoriteIdentifiersPublisher: Published<[String]>.Publisher { get }
    @discardableResult
    func addToFavorites(_ id: String, isDipServer: Bool) throws -> [String]
    @discardableResult
    func removeFromFavorites(_ id: String, isDipServer: Bool) throws -> [String]
    func eraseAllFavorites()
    func getFavoriteDIPServerId() -> String?
    func isFavoriteServerWith(identifier: String, isDipServer: Bool) -> Bool
}

class FavoriteRegionUseCase: FavoriteRegionUseCaseType {
    static let favDipIdPreffix = "favDIP:"
    
    private let keychain: KeychainType
    
    init(keychain: KeychainType) {
        self.keychain = keychain
        self.favorites = favoriteIdentifiers
    }
    
    
    var favoriteIdentifiers: [String] {
        if let favorites = try? keychain.getFavorites() {
            return favorites
        }
        
        return []
    }
    
    @Published internal var favorites: [String] = []
    
    var favoriteIdentifiersPublisher: Published<[String]>.Publisher {
        $favorites
    }
    
    @discardableResult
    func addToFavorites(_ id: String, isDipServer: Bool) throws -> [String] {
        var newFavorites = favoriteIdentifiers
        let newFavoriteId = isDipServer ? calculateServerIdForDipServer(id) : id
        newFavorites.append(newFavoriteId)
        try keychain.set(favorites: newFavorites)
        favorites = newFavorites
        return newFavorites
    }
    
    @discardableResult
    func removeFromFavorites(_ id: String, isDipServer: Bool) throws -> [String] {
        let storedFavoriteId = isDipServer ? calculateServerIdForDipServer(id) : id
        let newFavorites = favoriteIdentifiers.filter { storedFavoriteId != $0 }
        try keychain.set(favorites: newFavorites)
        favorites = newFavorites
        return newFavorites
    }
    
    func eraseAllFavorites() {
        do {
            try keychain.eraseAllFavorites()
            self.favorites = []
        } catch {
            // No op
        }
         
    }
    
    private func calculateServerIdForDipServer(_ id: String) -> String {
        return "\(Self.favDipIdPreffix)\(id)"
    }
    
    func getFavoriteDIPServerId() -> String? {
        guard let storedFavIdWithPreffix = favoriteIdentifiers.filter { $0.hasPrefix(Self.favDipIdPreffix) }.first else {
            return nil
        }
        
        let dipServerIdWithoutPreffix = String(storedFavIdWithPreffix.dropFirst(Self.favDipIdPreffix.count))
        
        return dipServerIdWithoutPreffix
    }
    
    func isFavoriteServerWith(identifier: String, isDipServer: Bool) -> Bool {
        if isDipServer {
            guard let savedFavoriteDipServerId = getFavoriteDIPServerId() else { return false }
            return savedFavoriteDipServerId == identifier
        } else {
            return favoriteIdentifiers.contains(identifier)
        }
        
    }
}
