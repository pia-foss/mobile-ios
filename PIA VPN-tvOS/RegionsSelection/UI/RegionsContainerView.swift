//
//  RegionsContainerView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/19/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct RegionsContainerView: View {
    let viewWidth = UIScreen.main.bounds.width
    let viewHeight = UIScreen.main.bounds.height
    
    @ObservedObject var viewModel: RegionsContainerViewModel
    
    var sideMenuButtons: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.sideMenuItems) { menuItem in
                Button {
                    viewModel.navigate(to: menuItem)
                } label: {
                    Text(menuItem.text)
                }
            }
        }
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            switch viewModel.selectedSideMenuItem {
            case .all:
                HStack(alignment: .top) {
                    sideMenuButtons
                    VStack {
                        RegionsSelectionFactory.makeRegionsListView()
                    }
                }
            case .favourites:
                HStack(alignment: .top) {
                    sideMenuButtons
                    VStack {
                        RegionsSelectionFactory.makeRegionsListView()
                    }
                }
            case .search:
                EmptyView()
            }
            
        }.navigationDestination(for: RegionSelectionDestinations.self) { route in
            switch route {
            case .search:
                let regionsView = RegionsSelectionFactory.makeRegionsListView()
                
                regionsView
                    .searchable(text: regionsView.$viewModel.search, placement: SearchFieldPlacement.automatic)
            }
        }
        
        
    }
}

#Preview {
    RegionsContainerView(viewModel: RegionsSelectionFactory.makeRegionsContainerViewModel())
}
