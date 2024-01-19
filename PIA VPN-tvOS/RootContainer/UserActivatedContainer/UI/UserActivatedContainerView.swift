//
//  UserActivatedContainerView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct UserActivatedContainerView: View {
    
    @ObservedObject var router: AppRouter
    
    var body: some View {
        DashboardFactory.makeDashboardView()
            .navigationDestination(for: RegionsDestinations.self) { destination in
                switch destination {
                case .serversList:
                    RegionsSelectionFactory.makeRegionsContainerView()
                case .selectServer(let selectedServer):
                    VStack {
                        Text("Selected server: \(selectedServer.name)")
                    }
                }
            }
    }
    
}

