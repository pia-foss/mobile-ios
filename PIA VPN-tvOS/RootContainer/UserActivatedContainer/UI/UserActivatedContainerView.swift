//
//  UserActivatedContainerView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Combine



struct UserActivatedContainerView: View {
    
    var body: some View {
        DashboardFactory.makeDashboardView()
            .navigationDestination(for: RegionsDestinations.self) { destination in
                switch destination {
                case .serversList:
                    RegionsSelectionFactory.makeRegionsContainerView()
                        .padding(.top, Spacing.screenTopPadding)
                        .navigationBarItems(leading: TopNavigationFactory.makeLeadingSegmentedNavigationView())
                        .navigationTitle(L10n.Localizable.TopNavigationBar.LocationSelectionScreen.title)
                        .navigationBarItems(trailing: TopNavigationFactory.makeTrailingNavigationView())
                case .search:
                    RegionsSelectionFactory.makeSearchRegionsListView()
                        .navigationBarHidden(true)
                }
            }
        
    }
    
}

