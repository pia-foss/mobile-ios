//
//  DashboardCollectionViewUtil.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 21/03/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit

enum Cells: Int, EnumsBuilder {
    
    case region = 0
    case quickConnect
    case ipTile
    case subscription
    case usage
    case networkManagementTool
    case quickSettings
    case favoriteServers

    var identifier: String {
        switch self {
        case .ipTile: return "IPTileCell"
        case .quickConnect: return "QuickConnectTileCell"
        case .region: return "RegionTileCell"
        case .subscription: return "SubscriptionTileCell"
        case .usage: return "UsageTileCell"
        case .networkManagementTool: return "NMTTileCell"
        case .quickSettings: return "QuickSettingsTileCell"
        case .favoriteServers: return "FavoriteServersTileCell"
        }
    }
    
    var className: String {
        switch self {
        case .ipTile: return "IPTileCollectionViewCell"
        case .quickConnect: return "QuickConnectTileCollectionViewCell"
        case .region: return "RegionTileCollectionViewCell"
        case .subscription: return "SubscriptionTileCollectionViewCell"
        case .usage: return "UsageTileCollectionViewCell"
        case .networkManagementTool: return "NetworkManagementToolTileCollectionViewCell"
        case .quickSettings: return "QuickSettingsTileCollectionViewCell"
        case .favoriteServers: return "FavoriteServersTileCollectionViewCell"
        }
    }
}

class DashboardCollectionViewUtil: NSObject {

    func registerCellsFor(_ collectionView: UICollectionView) {
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
        collectionView.register(UINib(nibName: Cells.networkManagementTool.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.networkManagementTool.identifier)
        collectionView.register(UINib(nibName: Cells.quickSettings.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.quickSettings.identifier)
        collectionView.register(UINib(nibName: Cells.favoriteServers.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.favoriteServers.identifier)
        collectionView.backgroundColor = .clear
    }
    

}
