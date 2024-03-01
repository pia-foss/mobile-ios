//
//  KeychainTypeMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class KeychainTypeMock: KeychainType {
    
    var eraseAllFavoritesCalled = false
    var eraseAllFavoritesCalledAttempt = 0
    var eraseAllFavoritesResultError: Error?
    func eraseAllFavorites() throws {
        eraseAllFavoritesCalled = true
        eraseAllFavoritesCalledAttempt += 1
        if let error = eraseAllFavoritesResultError {
            throw error
        }
    }
    
    var getFavoritesCalled = false
    var getFavoritesCalledAttempt = 0
    var getFavoritesResultError: Error?
    var getFavoritesResultSuccess: [String]?
    func getFavorites() throws -> [String] {
        getFavoritesCalled = true
        getFavoritesCalledAttempt += 1
        
        if let error = getFavoritesResultError {
            throw error
        } else {
            return getFavoritesResultSuccess!
        }
    }
    
    
    var setFavoritesCalled = false
    var setFavoritesCalledAttempt = 0
    var setFavoritesCalledWithArgument: [String]?
    var setFavoritesResultError: Error?
    func set(favorites: [String]) throws {
        setFavoritesCalled = true
        setFavoritesCalledAttempt += 1
        setFavoritesCalledWithArgument = favorites
        
        if let error = setFavoritesResultError {
            throw error
        }
    }
    
    
}
