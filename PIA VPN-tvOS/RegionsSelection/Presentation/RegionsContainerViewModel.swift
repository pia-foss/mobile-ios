//
//  RegionsContainerViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/19/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

class RegionsContainerViewModel: ObservableObject {
    enum RegionSelectionSideMenuItems: CaseIterable, Identifiable {
        case all
        case search
        case favourites
        
        var id: Self {
            return self
        }
        
        var text: String {
            switch self {
            case .all:
                return L10n.Localizable.RegionsView.SplitMenu.AllItem.title
            case .search:
                return L10n.Localizable.RegionsView.SplitMenu.SearchItem.title
            case .favourites:
                return L10n.Localizable.RegionsView.SplitMenu.FavoritesItem.title
            }
        }
    }
    
    @Published var sideMenuItems: [RegionSelectionSideMenuItems] = RegionSelectionSideMenuItems.allCases
    
    @Published private(set) var selectedSideMenuItem: RegionSelectionSideMenuItems = .all
    
    private let onSearchSelectedAction: AppRouter.Actions
    
    init(onSearchSelectedAction: AppRouter.Actions) {
        self.onSearchSelectedAction = onSearchSelectedAction
    }
    
    func navigate(to route: RegionSelectionSideMenuItems) {
        if route == .search {
            onSearchSelectedAction()
        } else {
            selectedSideMenuItem = route
        }
        
    }
    
    
}
