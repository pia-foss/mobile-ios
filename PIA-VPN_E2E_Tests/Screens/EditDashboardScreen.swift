//
//  EditDashboardScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 18/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var quickConnectTileCell: XCUIElement {
        cell(with: "QuickConnectTileCollectionViewCell")
    }
    
    var ipTileCell: XCUIElement {
        cell(with: "IPTileCollectionViewCell")
    }
    
    var subscriptionTileCell: XCUIElement {
        cell(with: "SubscriptionTileCollectionViewCell")
    }
    
    var usageTileCell: XCUIElement {
        cell(with: "UsageTileCollectionViewCell")
    }
    
    var favoriteServersTileCell: XCUIElement {
        cell(with: "FavoriteServersTileCollectionViewCell")
    }
    
    var connectionTileCell: XCUIElement {
        cell(with: "ConnectionTileCollectionViewCell")
    }
    
    func navigateToEditDashboardScreen () {
        guard dashboardEditButton.exists else { return }
        dashboardEditButton.tap()
        WaitHelper.waitForElementToNotBeVisible(regionTileCell, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("RegionTileCollectionViewCell is not visible")})
    }
}
