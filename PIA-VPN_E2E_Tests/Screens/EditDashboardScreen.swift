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
    var doneEditingButton: XCUIElement { button(with: getString(key: "global.done", comment: "Done")) }

    func navigateToEditDashboardScreen() {
        XCTAssertTrue(dashboardEditButton.waitForElementToAppear(), "Dashboard edit button not found")
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

    /// Long-presses `tile` and drops it on `target`, taking the target's place.
    func moveTile(_ tile: XCUIElement, onto target: XCUIElement) {
        tile.press(forDuration: 1.0, thenDragTo: target, withVelocity: .slow, thenHoldForDuration: 0.5)
    }
}
