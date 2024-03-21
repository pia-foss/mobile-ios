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
        dashboardEditButton.waitForElementToAppear()
        dashboardEditButton.tap()
        XCTAssert(connectionButton.waitForElementToBeHidden())
    }
    
    func addTile(tileName: XCUIElement) {
        let addTileButton = tileName.buttons["Tap to add this tile to the dashboard"]
        let removeTileButton = tileName.buttons["Tap to remove this tile from the dashboard"]
        
        if (removeTileButton.waitForElementToAppear()) {
            return
        }
        addTileButton.tap()
        
        XCTAssert(removeTileButton.waitForElementToAppear())
        XCTAssert(addTileButton.waitForElementToBeHidden())
    }
    
    func removeTile(tileName: XCUIElement) {
        let addTileButton = tileName.buttons["Tap to add this tile to the dashboard"]
        let removeTileButton = tileName.buttons["Tap to remove this tile from the dashboard"]
        
        if (addTileButton.waitForElementToAppear()) {
            return
        }
        removeTileButton.tap()
        
        XCTAssert(addTileButton.waitForElementToAppear())
        XCTAssert(removeTileButton.waitForElementToBeHidden())
    }
    
    func moveTile(firstTileName: XCUIElement, secondTileName: XCUIElement) {
        let moveButton = firstTileName.images["drag-drop-indicator-light"]
        moveButton.press(forDuration: 2.0, thenDragTo: secondTileName)
    }
}
