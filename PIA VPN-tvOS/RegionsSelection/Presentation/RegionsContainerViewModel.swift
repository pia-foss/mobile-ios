//
//  RegionsContainerViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/19/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

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
    
    @Published var sideMenuItems: [RegionsNavigationItems] = [.all, .search]
    
    @Published var selectedSection: RegionsNavigationItems = .all
    
    var searchButtonTitle: String {
        L10n.Localizable.Regions.Search.Button.title
    }
    
    private let favoritesUseCase: FavoriteRegionUseCaseType
    private let onSearchSelectedAction: AppRouter.Actions
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesUseCase: FavoriteRegionUseCaseType, onSearchSelectedAction: AppRouter.Actions) {
        self.favoritesUseCase = favoritesUseCase
        self.onSearchSelectedAction = onSearchSelectedAction
        subscribeToFavoritesUpdates()
    }
    
    func navigate(to route: RegionsNavigationItems) {
        selectedSection = route
        
        if route == .search {
            onSearchSelectedAction()
        }
        
    }
    
    /// When the focus moves back to the side menu buttons from the regions grid list
    /// then we keep the focus on the current selected side menu in order to provide a better UX
    func isRegionNavigationItemDisabled(_ item: RegionsNavigationItems, when focusedItem: RegionsNavigationItems?) -> Bool {
        
        let isSideMenuSectionOutOfFocus = focusedItem == nil
        
        switch (isSideMenuSectionOutOfFocus, item == selectedSection) {
            /// Side buttons out of focus, the side menu item is the current selected section
        case (true, true):
            return false
            /// Side buttons out of focus, the side menu item is not the current selected section
        case (true, false):
            return true
            /// Side buttons are not out of focus, any side item selected
        case(false, _):
            return false
        }
        
    }
    
}

// MARK: - Private

extension RegionsContainerViewModel {
    private func subscribeToFavoritesUpdates() {
        favoritesUseCase.favoriteIdentifiersPublisher
            .receive(on: RunLoop.main)
            .sink {[weak self] newFavorites in
                guard let self else { return }
                if newFavorites.isEmpty {
                    self.sideMenuItems = [.all, .search]
                    if selectedSection == .favorites {
                        selectedSection = .all
                    }
                } else {
                    self.sideMenuItems = [.favorites, .all, .search]
                }
            }.store(in: &cancellables)
    }
}
