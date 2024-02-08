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
                        // TODO: Check .toolbar() to add the navigation bar because
                        // these APIs will be deprecated
                        .navigationBarItems(leading: TopNavigationFactory.makeLeadingSegmentedNavigationView())
                        .navigationTitle(L10n.Localizable.TopNavigationBar.LocationSelectionScreen.title)
                        .navigationBarItems(trailing: TopNavigationFactory.makeTrailingNavigationView())
                case .search:
                    RegionsSelectionFactory.makeSearchRegionsListView()
                        .navigationBarHidden(true)
                }
            }
            .navigationBarItems(leading: TopNavigationFactory.makeLeadingSegmentedNavigationView())
            .navigationBarItems(trailing: TopNavigationFactory.makeTrailingNavigationView())
            .navigationTitle("") // TODO: Inject the VPN connection status here
        
    }
    
}

