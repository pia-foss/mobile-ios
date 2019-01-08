//
//  Server+Favorite.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 28/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

protocol Favoritable {
    
    /// Favorite this server and update the cached servers
    func favorite()
    
    /// Unfavorite this server and update the cached servers
    func unfavorite()
    
}

extension Server: Favoritable, PropertyStoring {
    
    typealias T = Bool
    
    private struct CustomProperties {
        static var isFavorite = false
    }
    
    var isFavorite: Bool {
        get {
            return getAssociatedObject(&CustomProperties.isFavorite, defaultValue: CustomProperties.isFavorite)
        }
        set {
            return objc_setAssociatedObject(self, &CustomProperties.isFavorite, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func favorite() {
        self.isFavorite = true
        var currentFavorites = AppPreferences.shared.favoriteServerIdentifiers
        currentFavorites.append(self.identifier)
        AppPreferences.shared.favoriteServerIdentifiers = currentFavorites
    }
    
    func unfavorite() {
        self.isFavorite = false
        let currentFavorites = AppPreferences.shared.favoriteServerIdentifiers
        let filteredFavorites = currentFavorites.filter({$0 != self.identifier})
        AppPreferences.shared.favoriteServerIdentifiers = filteredFavorites
    }
    
}
