//
//  Server+Favorite.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 28/12/2018.
//  Copyright © 2020 Private Internet Access Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
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
