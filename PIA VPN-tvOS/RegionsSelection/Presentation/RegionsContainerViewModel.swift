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
    enum RegionsNavigationItems: CaseIterable, Identifiable {
        case all
        case search
        case favorites
        
        var id: Self {
            return self
        }
        
        var text: String {
            switch self {
            case .all:
                return L10n.Localizable.Regions.Filter.All.title
            case .search:
                return L10n.Localizable.Regions.Filter.Search.title
            case .favorites:
                return L10n.Localizable.Regions.Filter.Favorites.title
            }
        }
    }
    
    @Published var sideMenuItems: [RegionsNavigationItems] = RegionsNavigationItems.allCases
    
    @Published var selectedSection: RegionsNavigationItems = .all
    
    var searchButtonTitle: String {
        L10n.Localizable.Region.Search.placeholder
    }

    private let onSearchSelectedAction: AppRouter.Actions
    
    init(onSearchSelectedAction: AppRouter.Actions) {
        self.onSearchSelectedAction = onSearchSelectedAction
    }
    
    func navigate(to route: RegionsNavigationItems) {
        selectedSection = route
        
        if route == .search {
            onSearchSelectedAction()
        }
        
    }
    
    
}
