//
//  LeadingSegmentedNavigationViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class TopNavigationViewModel: ObservableObject {
    
    let appRouter: AppRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    let leadingSections: [Sections] = [.vpn, .locations]
    
    // TODO: Add 'help' section in the trailing sections when we implement it
    let trailingSections: [Sections] = [.settings]
    
    enum Sections: Equatable, Hashable, Identifiable {
        var id: Self {
            return self
        }
        
        case vpn
        case locations
        case settings
        case help
        
        var title: String {
            switch self {
            case .vpn:
                return L10n.Localizable.TopNavigationBar.VpnItem.title
            case .locations:
                return L10n.Localizable.TopNavigationBar.LocationItem.title
            case .settings:
                // The settings section does not have title (just an icon image)
                return ""
            case .help:
                // The help section does not have title (just an icon image)
                return ""
            }
        }
        
        var systemIconName: String {
            switch self {
            case .help:
                return "questionmark.circle"
            case .settings:
                return "gearshape"
            default:
                return ""
            }

        }
    }
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
        self.selectedSection = calculateSelectedSection(for: appRouter.pathDestinations)
        subscribeToAppRouterDestinationsUpdates()
    }
    
    @Published var selectedSection: Sections = .vpn
    @Published var highlightedSection: Sections? = nil
    
    func sectionDidUpdateSelection(to section: Sections) {
        guard section != selectedSection else { return }
        selectedSection = section
        
        switch section {
        case .vpn:
            appRouter.goBackToRoot()
        case .locations:
            appRouter.navigate(to: RegionsDestinations.serversList)
        case .settings:
            appRouter.navigate(to: SettingsDestinations.availableSettings)
            break
        case .help:
            // TODO: Implement me
            break
        }
    }
    
    func sectionDidUpdateFocus(to section: Sections?) {
        highlightedSection = section
    }
    
    func viewDidAppear() {
        // Remove the focus when the view appears
        sectionDidUpdateFocus(to: nil)
    }
    
    private func calculateSelectedSection(for pathDestinations: [any Destinations]) -> Sections {
        
        if let currentPath = pathDestinations.last {
            switch currentPath {
            case .serversList as RegionsDestinations:
                return .locations
            case .search as RegionsDestinations:
                return .locations
            case .home as DashboardDestinations:
                 return .vpn
            case .availableSettings as SettingsDestinations:
                return .settings
            case .account as SettingsDestinations:
                return .settings
            case .general as SettingsDestinations:
                return .settings
            case .dip as SettingsDestinations:
                return .settings
            // TODO: add help destinations when implemented
            default:
                return .vpn
            }
        } else {
            // The path is empty, so we are in the root
             return .vpn
        }
        
    }
    
    private func subscribeToAppRouterDestinationsUpdates() {
        appRouter.$pathDestinations
            .sink { [weak self] newPathDestinations in
                guard let self = self else { return }
                self.selectedSection = self.calculateSelectedSection(for: newPathDestinations)
            }.store(in: &cancellables)
    }
    
}
