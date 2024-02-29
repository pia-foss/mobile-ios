//
//  FavoriteRegionsUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import PIA_VPN_tvOS
import PIALibrary

class FavoriteRegionsUseCaseTests: XCTestCase {
    class Fixture {
        let keychainMock = KeychainTypeMock()
    }
    
    var fixture: Fixture!
    var sut: FavoriteRegionUseCase!
    var favoritesPublishedValues: [String] = []
    var cancellables = Set<AnyCancellable>()
    
    
    override func setUp() {
        fixture = Fixture()
        favoritesPublishedValues = []
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = FavoriteRegionUseCase(keychain: fixture.keychainMock)
    }
    
    private func subscribeToPublishedFavorites() {
        sut.favoriteIdentifiersPublisher
            .sink { [weak self] newFavs in
                self?.favoritesPublishedValues = newFavs
            }.store(in: &cancellables)
    }
    
    
    func test_addToFavorites_NoDipServer_whenKeychainSucceeds() throws {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to save a favorite into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        subscribeToPublishedFavorites()
        // The initial value of the published favorites contains one item
        XCTAssertEqual(favoritesPublishedValues.count, 1)
        
        // WHEN adding a new item that is not a DIP server to the favorites list
        let newFavorites = try sut.addToFavorites("server-id-two", isDipServer: false)

        // THEN the new item id is added to the list of favorites
        XCTAssertEqual(newFavorites.count, 2)
        XCTAssertEqual(["server-id-one", "server-id-two"], newFavorites)
        // AND the new value is also publised on the favorites publisher
        XCTAssertEqual(favoritesPublishedValues.count, 2)
    }
    
    func test_addToFavorites_NoDipServer_whenKeychainFails() {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that AN error is thrown when trying to save a favorite into the Keychain
        fixture.keychainMock.setFavoritesResultError = KeychainError.add
        instantiateSut()
        
        // WHEN adding a new item that is not a DIP server to the favorites list
        // THEN an error is thrown
        XCTAssertThrowsError(try sut.addToFavorites("server-id-two", isDipServer: false))

    }
    
    
    func test_removeFavorites_NoDipServer_whenKeychainSucceeds() throws {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        subscribeToPublishedFavorites()
        // The initial value of the published favorites contains one item
        XCTAssertEqual(favoritesPublishedValues.count, 1)
        
        // WHEN removing the item from the favorites list
        let newFavorites = try sut.removeFromFavorites("server-id-one", isDipServer: false)
        // THEN the item is removed from the favorites list
        XCTAssertEqual(newFavorites.count, 0)
        XCTAssertEqual([], newFavorites)
        // AND the favorites publisher is also updated with the empty list of favorites
        XCTAssertEqual(favoritesPublishedValues.count, 0)
        
    }
    
    func test_removeFromFavorites_NoDipServer_whenKeychainFails() {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that AN error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = KeychainError.add
        instantiateSut()
        
        // WHEN removing the item from the favorites list
        // THEN an error is thrown
        XCTAssertThrowsError(try sut.removeFromFavorites("server-id-one", isDipServer: false))

    }
    
    func test_addToFavorites_DipServer_whenKeychainSucceeds() throws {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to save a favorite into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        
        // WHEN adding a new item that is a DIP server to the favorites list
        let newFavorites = try sut.addToFavorites("server-id-two", isDipServer: true)

        // THEN the new item id with the DIP preffix is added to the list of favorites
        XCTAssertEqual(newFavorites.count, 2)
        XCTAssertEqual(["server-id-one", "favDIP:server-id-two"], newFavorites)
        
    }
    
    func test_addToFavorites_DipServer_whenKeychainFails() {
        // GIVEN that there is one item saved to favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that AN error is thrown when trying to save a favorite into the Keychain
        fixture.keychainMock.setFavoritesResultError = KeychainError.add
        instantiateSut()
        
        // WHEN adding a new item that is a DIP server to the favorites list
        // THEN an error is thrown
        XCTAssertThrowsError(try sut.addToFavorites("server-id-two", isDipServer: true))

    }
    
    func test_removeFavorites_DipServer_whenKeychainSucceeds() throws {
        // GIVEN that "server-id-one" is saved to favorites as a favorite DIP server
        fixture.keychainMock.getFavoritesResultSuccess = ["favDIP:server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        
        // WHEN calling to remove "server-id-one" as a dip server from the favorites list
        let newFavorites = try sut.removeFromFavorites("server-id-one", isDipServer: true)
        // THEN the item is removed from the favorites list
        XCTAssertEqual(newFavorites.count, 0)
        XCTAssertEqual([], newFavorites)
        
    }
    
    func test_removeFromFavorites_DipServer_whenKeychainFails() {
        // GIVEN that "server-id-one" is saved to favorites as a favorite DIP server
        fixture.keychainMock.getFavoritesResultSuccess = ["favDIP:server-id-one"]
        
        // AND GIVEN that AN error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = KeychainError.add
        instantiateSut()
        
        // WHEN calling to remove "server-id-one" as a dip server from the favorites list
        // THEN an error is thrown
        XCTAssertThrowsError(try sut.removeFromFavorites("server-id-one", isDipServer: true))
    }
    
    func test_addToFavorites_sameServer_withDIP() throws {
        // GIVEN that there is one item saved to favorites that is NOT a DIP Server
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        
        // WHEN trying to add the same item id, but as a DIP server to the list
        let newFavorites = try sut.addToFavorites("server-id-one", isDipServer: true)

        // THEN the new item id with the DIP preffix is added to the list of favorites
        XCTAssertEqual(newFavorites.count, 2)
        XCTAssertEqual(["server-id-one", "favDIP:server-id-one"], newFavorites)
    }
    
    func test_removeFromFavorites_sameServer_withDIP() throws {
        // GIVEN that there is one item saved to favorites that is NOT a DIP Server
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one"]
        
        // AND GIVEN that no error is thrown when trying to set the favorites into the Keychain
        fixture.keychainMock.setFavoritesResultError = nil
        instantiateSut()
        
        // WHEN trying to remove the same item id, but as a DIP server to the list
        let newFavorites = try sut.removeFromFavorites("server-id-one", isDipServer: true)

        // THEN nothing gets removed and the favorites list remains with 1 item
        XCTAssertEqual(newFavorites.count, 1)
        XCTAssertEqual(["server-id-one"], newFavorites)
    }
    
    func test_getFavoriteDIPServerId_when_DipIsFavorite() {
        // GIVEN that there is one item saved to favorites that is NOT a DIP Server, and one that is a DIP server
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one", "favDIP:server-id-two"]
        
        instantiateSut()
        
        // WHEN getting the id of the favorite DIP server
        let favoriteDIPServerId = sut.getFavoriteDIPServerId()
        
        // THEN the server id is returned without the fav DIP preffix
        XCTAssertEqual(favoriteDIPServerId, "server-id-two")
        
    }
    
    func test_getFavoriteDIPServerId_when_DipIsNotFavorite() {
        // GIVEN that no DIP item is stored in the favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one", "server-id-two"]
        
        instantiateSut()
        
        // WHEN getting the id of the favorite DIP server
        let favoriteDIPServerId = sut.getFavoriteDIPServerId()
        
        // THEN the returned value is nil
        XCTAssertNil(favoriteDIPServerId)
        
    }
    
    
    func test_isFavorite_whenNoDipServerIsSaved() {
        // GIVEN that no DIP item is stored in the favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one", "server-id-two"]
        
        instantiateSut()
        
        // WHEN calculating if "server-id-two" is favorite as a No Dip Server
        let isServerTwoFavoriteAsNoDip = sut.isFavoriteServerWith(identifier: "server-id-two", isDipServer: false)
        // THEN the result is true
        XCTAssertTrue(isServerTwoFavoriteAsNoDip)
        
        // WHEN calculating if "server-id-two" is favorite as a Dip Server
        let isServerTwoFavoriteAsDip = sut.isFavoriteServerWith(identifier: "server-id-two", isDipServer: true)
        // THEN the result is false
        XCTAssertFalse(isServerTwoFavoriteAsDip)
        
    }
    
    func test_isFavorite_whenADipServerIsSaved() {
        // GIVEN that a DIP item is stored in the favorites
        fixture.keychainMock.getFavoritesResultSuccess = ["server-id-one", "favDIP:server-id-two"]
        
        instantiateSut()
        
        // WHEN calculating if "server-id-two" is favorite as a No Dip Server
        let isServerTwoFavoriteAsNoDip = sut.isFavoriteServerWith(identifier: "server-id-two", isDipServer: false)
        // THEN the result is false
        XCTAssertFalse(isServerTwoFavoriteAsNoDip)
        
        // WHEN calculating if "server-id-two" is favorite as a Dip Server
        let isServerTwoFavoriteAsDip = sut.isFavoriteServerWith(identifier: "server-id-two", isDipServer: true)
        // THEN the result is true
        XCTAssertTrue(isServerTwoFavoriteAsDip)
        
    }
    
}
