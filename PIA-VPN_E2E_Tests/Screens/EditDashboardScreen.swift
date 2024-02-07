//
//  EditDashboardScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 18/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var quickConnectTileCollectionViewCell: XCUIElement {
        cell(with: "QuickConnectTileCollectionViewCell")
    }
    
    var ipTileCollectionViewCell: XCUIElement {
        cell(with: "IPTileCollectionViewCell")
    }
    
    var subscriptionTileCollectionViewCell: XCUIElement {
        cell(with: "SubscriptionTileCollectionViewCell")
    }
    
    var usageTileCollectionViewCell: XCUIElement {
        cell(with: "UsageTileCollectionViewCell")
    }
    
    var favoriteServersTileCollectionViewCell: XCUIElement {
        cell(with: "FavoriteServersTileCollectionViewCell")
    }
    
    var connectionTileCollectionViewCell: XCUIElement {
        cell(with: "ConnectionTileCollectionViewCell")
    }
    
    var cancelButton: XCUIElement {
        button(with: "Cancel")
    }
    
    func navigateToEditDashboardScreen() {
        guard dashboardEditButton.waitForExistence(timeout: defaultTimeout) else { return }
        dashboardEditButton.tap()
        WaitHelper.waitForElementToNotBeVisible(regionTileCollectionViewCell, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("RegionTileCollectionViewCell is not visible")})
    }
    
    func addTile(tileName: XCUIElement) {
        let addTileButton = tileName.buttons["Tap to add this tile to the dashboard"]
        let removeTileButton = tileName.buttons["Tap to remove this tile from the dashboard"]
        
        if(addTileButton.waitForExistence(timeout: defaultTimeout)) {
            addTileButton.tap()
        }
        
        WaitHelper.waitForElementToBeVisible(removeTileButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("removeTileButton is not visible")})
        WaitHelper.waitForElementToNotBeVisible(addTileButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("addTileButton is visible")})
    }
    
    func removeTile(tileName: XCUIElement) {
        let addTileButton = tileName.buttons["Tap to add this tile to the dashboard"]
        let removeTileButton = tileName.buttons["Tap to remove this tile from the dashboard"]
        
        if(removeTileButton.waitForExistence(timeout: defaultTimeout)) {
            removeTileButton.tap()
        }
        
        WaitHelper.waitForElementToBeVisible(addTileButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("removeTileButton is not visible")})
        WaitHelper.waitForElementToNotBeVisible(removeTileButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("addTileButton is visible")})
    }
    
    func moveTile(firstTileName: XCUIElement, secondTileName: XCUIElement) {
        let moveButton = firstTileName.images["drag-drop-indicator-light"]
        moveButton.press(forDuration: 1.0, thenDragTo: secondTileName)
    }
}
