//
//  DashboardCollectionViewUtil.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 21/03/2019.
//  Copyright © 2020 Private Internet Access, Inc.
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

import UIKit

enum DashboardSections: Int {
    case fixedTiles = 0
    case tiles
}

enum FixedCells: Int, EnumsBuilder {
    
    case messages = 0
    
    var identifier: String {
        switch self {
        case .messages: return "MessagesTileCell"
        }
    }
    
    var className: String {
        switch self {
        case .messages: return "MessagesTileCollectionViewCell"
        }
    }

}

enum Cells: Int, EnumsBuilder {
    
    case region = 0
    case quickConnect
    case ipTile
    case subscription
    case usage
    case quickSettings
    case favoriteServers
    case connectionTile
    
    var identifier: String {
        switch self {
        case .ipTile: return "IPTileCell"
        case .quickConnect: return "QuickConnectTileCell"
        case .region: return "RegionTileCell"
        case .subscription: return "SubscriptionTileCell"
        case .usage: return "UsageTileCell"
        case .quickSettings: return "QuickSettingsTileCell"
        case .favoriteServers: return "FavoriteServersTileCell"
        case .connectionTile: return "ConnectionTileCell"
        }
    }
    
    var className: String {
        switch self {
        case .ipTile: return "IPTileCollectionViewCell"
        case .quickConnect: return "QuickConnectTileCollectionViewCell"
        case .region: return "RegionTileCollectionViewCell"
        case .subscription: return "SubscriptionTileCollectionViewCell"
        case .usage: return "UsageTileCollectionViewCell"
        case .quickSettings: return "QuickSettingsTileCollectionViewCell"
        case .favoriteServers: return "FavoriteServersTileCollectionViewCell"
        case .connectionTile: return "ConnectionTileCollectionViewCell"
        }
    }
}

class DashboardCollectionViewUtil: NSObject {

    func registerCellsFor(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: FixedCells.messages.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: FixedCells.messages.identifier)
        collectionView.register(UINib(nibName: Cells.ipTile.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.ipTile.identifier)
        collectionView.register(UINib(nibName: Cells.quickConnect.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.quickConnect.identifier)
        collectionView.register(UINib(nibName: Cells.region.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.region.identifier)
        collectionView.register(UINib(nibName: Cells.subscription.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.subscription.identifier)
        collectionView.register(UINib(nibName: Cells.usage.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.usage.identifier)
        collectionView.register(UINib(nibName: Cells.quickSettings.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.quickSettings.identifier)
        collectionView.register(UINib(nibName: Cells.favoriteServers.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.favoriteServers.identifier)
        collectionView.register(UINib(nibName: Cells.connectionTile.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.connectionTile.identifier)
        collectionView.backgroundColor = .clear
    }
    

}
