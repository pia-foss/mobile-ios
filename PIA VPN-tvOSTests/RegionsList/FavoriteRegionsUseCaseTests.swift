//
//  FavoriteRegionsUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary

class FavoriteRegionsUseCaseTests: XCTestCase {
    class Fixture {
        let keychainMock = KeychainTypeMock()
    }
    
    var fixture: Fixture!
    var sut: FavoriteRegionUseCase!
    
    func instantiateSut() {
        sut = FavoriteRegionUseCase(keychain: fixture.keychainMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    
    func test_addToFavorites_whenKeychainSucceeds() throws {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to save a favorite into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        
        // WHEN adding a new item to the favorites list
        let newFavorites = try sut.addToFavorites("server-id-two")
        // THEN the new item is added to the favorites list
        XCTAssertEqual(newFavorites.count, 2)
        XCTAssertEqual(["server-id-one", "server-id-two"], newFavorites)
        
    }
    
    func test_addToFavorites_whenKeychainFails() {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that AN error is thrown when trying to save a favorite into the Keychain
        fixture.keychainMock.setFavoritesResultError = KeychainError.add
        instantiateSut()
        
        // WHEN adding a new item to the favorites list
        // THEN an error is thrown
        XCTAssertThrowsError(try sut.addToFavorites("server-id-two"))

    }
    
    
    func test_removeFavorites_whenKeychainSucceeds() throws {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        
        // WHEN removing the item from the favorites list
        let newFavorites = try sut.removeFromFavorites("server-id-one")
        // THEN the item is removed from the favorites list
        XCTAssertEqual(newFavorites.count, 0)
        XCTAssertEqual([], newFavorites)
        
    }
    
    func test_removeFromFavorites_whenKeychainFails() {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that AN error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = KeychainError.add
        instantiateSut()
        
        // WHEN removing the item from the favorites list
        // THEN an error is thrown
        XCTAssertThrowsError(try sut.removeFromFavorites("server-id-one"))

    }
}
