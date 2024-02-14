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
                        .withTopNavigationBar(with: L10n.Localizable.TopNavigationBar.LocationSelectionScreen.title)
                case .search:
                    RegionsSelectionFactory.makeSearchRegionsListView()
                        .navigationBarHidden(true)
                }
            }
        
    }
    
}

