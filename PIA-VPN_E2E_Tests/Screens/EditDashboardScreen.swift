//
//  EditDashboardScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 18/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import PIAAccessibility
import XCTest

extension XCUIApplication {
    var quickConnectTileCollectionViewCell: XCUIElement { cell(with: AccessibilityID.Tiles.quickConnectCell) }
    var ipTileCollectionViewCell: XCUIElement { cell(with: AccessibilityID.Tiles.ipCell) }
    var subscriptionTileCollectionViewCell: XCUIElement { cell(with: AccessibilityID.Tiles.subscriptionCell) }
    var usageTileCollectionViewCell: XCUIElement { cell(with: AccessibilityID.Tiles.usageCell) }
    var favoriteServersTileCollectionViewCell: XCUIElement { cell(with: AccessibilityID.Tiles.favoriteServersCell) }
    var connectionTileCollectionViewCell: XCUIElement { cell(with: AccessibilityID.Tiles.connectionCell) }
    var cancelButton: XCUIElement { button(with: "Cancel") }

    func navigateToEditDashboardScreen() {
        dashboardEditButton.waitForElementToAppear()
        dashboardEditButton.tap()
        XCTAssertTrue(connectionButton.waitForElementToBeHidden())
    }

    func addTile(tileName: XCUIElement) {
        let addTileButton = tileName.buttons["Tap to add this tile to the dashboard"]
        let removeTileButton = tileName.buttons["Tap to remove this tile from the dashboard"]

        if (removeTileButton.waitForElementToAppear()) {
            return
        }
        addTileButton.tap()

        XCTAssertTrue(removeTileButton.waitForElementToAppear())
        XCTAssertTrue(addTileButton.waitForElementToBeHidden())
    }

    func removeTile(tileName: XCUIElement) {
        let addTileButton = tileName.buttons["Tap to add this tile to the dashboard"]
        let removeTileButton = tileName.buttons["Tap to remove this tile from the dashboard"]

        if (addTileButton.waitForElementToAppear()) {
            return
        }
        removeTileButton.tap()

        XCTAssertTrue(addTileButton.waitForElementToAppear())
        XCTAssertTrue(removeTileButton.waitForElementToBeHidden())
    }

    func moveTile(firstTileName: XCUIElement, secondTileName: XCUIElement) {
        let moveButton = firstTileName.images["drag-drop-indicator-light"]
        moveButton.press(forDuration: 2.0, thenDragTo: secondTileName)
    }
}
