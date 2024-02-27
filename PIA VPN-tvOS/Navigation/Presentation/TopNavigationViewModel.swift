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


class LeadingNavigationBarViewModel: ObservableObject {
    
    let appRouter: AppRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    let sections: [Sections] = [.vpn, .locations]
    
    enum Sections: Equatable, Hashable, Identifiable {
        var id: Self {
            return self
        }
        
        case vpn
        case locations
        
        var title: String {
            switch self {
            case .vpn:
                return L10n.Localizable.TopNavigationBar.VpnItem.title
            case .locations:
                return L10n.Localizable.TopNavigationBar.LocationItem.title
            }
        }
        
    }
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
        self.selectedSection = calculateSelectedSection(for: appRouter.pathDestinations)
        subscribeToAppRouterDestinationsUpdates()
    }
    
    @Published var selectedSection: Sections? = nil
    @Published var highlightedSection: Sections? = nil
    
    func sectionDidUpdateSelection(to section: Sections) {
        guard section != selectedSection else { return }
        selectedSection = section
        
        switch section {
        case .vpn:
            appRouter.goBackToRoot()
        case .locations:
            // Empty the current navigation path before pushing the Regions root flow
            appRouter.goBackToRoot()
            appRouter.navigate(to: RegionsDestinations.serversList)
        }
    }
    
    
    func sectionDidUpdateFocus(to section: Sections?) {
        highlightedSection = section
    }
    
    func viewDidAppear() {
        // Remove the focus when the view appears
        sectionDidUpdateFocus(to: nil)
    }
    
    private func calculateSelectedSection(for pathDestinations: [any Destinations]) -> Sections? {
        
        if let currentPath = pathDestinations.last {
            switch currentPath {
            case .serversList as RegionsDestinations:
                return .locations
            case .search as RegionsDestinations:
                return .locations
            case .home as DashboardDestinations:
                 return .vpn
            default:
                return nil
            }
        } else {
            // The path is empty, so we are in the root of the NavigationStack (.vpn)
             return .vpn
        }
        
    }
    
    private func subscribeToAppRouterDestinationsUpdates() {
        appRouter.$pathDestinations
            .receive(on: RunLoop.main)
            .sink { [weak self] newPathDestinations in
                guard let self = self else { return }
                self.selectedSection = self.calculateSelectedSection(for: newPathDestinations)
            }.store(in: &cancellables)
    }
    
}


class TrailingNavigationBarViewModel: ObservableObject {
    
    let appRouter: AppRouter
    
    private var cancellables = Set<AnyCancellable>()
    
    let sections: [Sections] = [.settings(.root), .help(.root)]
    
    enum Sections: Equatable, Hashable, Identifiable {
        var id: Self {
            return self
        }
        
        case settings(SettingsPath = .root)
        case help(HelpPath = .root)
        
        var systemIconName: String {
            switch self {
            case .help:
                return "questionmark.circle"
            case .settings:
                return "gearshape"
            }

        }
        
        enum SettingsPath: Equatable {
            case root, account, general, dedicatedIp
        }
        
        enum HelpPath: Equatable {
            case root, about, acknowledgements, privacyPolicy
        }
    }
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
        self.selectedSection = calculateSelectedSection(for: appRouter.pathDestinations)
        subscribeToAppRouterDestinationsUpdates()
    }
    
    @Published var selectedSection: Sections? = nil
    @Published var highlightedSection: Sections? = nil
    
    func sectionDidUpdateSelection(to section: Sections) {
        guard section != selectedSection else { return }
        selectedSection = section
        
        switch section {
        case .settings:
            // Empty the current navigation path before pushing the settings root flow
            appRouter.goBackToRoot()
            appRouter.navigate(to: SettingsDestinations.availableSettings)
        case .help:
            // Empty the current navigation path before pushing the help root flow
            appRouter.goBackToRoot()
            appRouter.navigate(to: HelpDestinations.root)
        }
    }
    
    
    func sectionDidUpdateFocus(to section: Sections?) {
        highlightedSection = section
    }
    
    func viewDidAppear() {
        // Remove the focus when the view appears
        sectionDidUpdateFocus(to: nil)
    }
    
    private func calculateSelectedSection(for pathDestinations: [any Destinations]) -> Sections? {
        
        if let currentPath = pathDestinations.last {
            switch currentPath {
            case .availableSettings as SettingsDestinations:
                return .settings(.root)
            case .account as SettingsDestinations:
                return .settings(.account)
            case .general as SettingsDestinations:
                return .settings(.general)
            case .dip as SettingsDestinations:
                return .settings(.dedicatedIp)
            case .root as HelpDestinations:
                return .help(.root)
            case .about as HelpDestinations:
                return .help(.about)
            case .acknowledments as HelpDestinations:
                return .help(.acknowledgements)
            case .privacyPolicy as HelpDestinations:
                return .help(.privacyPolicy)
            default:
                return nil
            }
        } else {
             return nil
        }
        
    }
    
    private func subscribeToAppRouterDestinationsUpdates() {
        appRouter.$pathDestinations
            .receive(on: RunLoop.main)
            .sink { [weak self] newPathDestinations in
                guard let self = self else { return }
                self.selectedSection = self.calculateSelectedSection(for: newPathDestinations)
            }.store(in: &cancellables)
    }
    
}
