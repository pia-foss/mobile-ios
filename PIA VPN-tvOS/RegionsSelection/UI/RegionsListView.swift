//
//  RegionsListView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct RegionsListView: View {
    
    @ObservedObject var viewModel: RegionsListViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 376, maximum: 376), spacing: 40)
    ]
    
    private func contextMenuItem(for server: ServerType) -> RegionsListItemButton.ContextMenuItem {
        RegionsListItemButton.ContextMenuItem.item(
            label: RegionsListItemButton.ContextMenuLabel(title: viewModel.favoriteContextMenuTitle(for: server), iconName: viewModel.favoriteIconName(for: server)),
            action: {
                viewModel.toggleFavorite(server: server)
            })
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                if !viewModel.optimalAndDIPServers.isEmpty {
                    optimalLocationAndDIPLocationSection
                }
                
                if let title = viewModel.regionsListTitle {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(Color.pia_on_surface_container_secondary)
                }
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 40) {
                    ForEach(viewModel.servers, id: \.id) { server in
                        RegionsListItemButton(
                            onRegionItemSelected: {
                                viewModel.didSelectRegionServer(server)
                            },
                            iconName: viewModel.getIconImageName(for: server).unfocused,
                            highlightedIconName: viewModel.getIconImageName(for: server).focused,
                            title: viewModel.getDisplayName(for: server).title,
                            subtitle: viewModel.getDisplayName(for: server).subtitle,
                            favoriteIconName: viewModel.favoriteIconName(for: server),
                            contextMenuItem: contextMenuItem(for: server)
                        )
                        
                    }
                }
                
            }.onAppear {
                viewModel.viewDidAppear()
            }
            
        }
        
    }
}


// MARK: - Optimal Location and DIP Locations

extension RegionsListView {
    
    var optimalLocationAndDIPLocationSection: some View {
        VStack(alignment: .leading) {
            if let title = viewModel.optimalAndDIPServersSectionTitle {
                Text(title)
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(Color.pia_on_surface_container_secondary)
            }
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 40) {
                ForEach(viewModel.optimalAndDIPServers, id: \.identifier) { server in
                    RegionsListItemButton(
                        onRegionItemSelected: {
                            viewModel.didSelectRegionServer(server)
                        },
                        iconName: server.dipToken == nil ? .smart_location_icon_name : .icon_dip_location,
                        highlightedIconName: server.dipToken == nil ? .smart_location_icon_highlighted_name : .icon_dip_location,
                        title: viewModel.getDisplayName(for: server).title,
                        subtitle: viewModel.getDisplayName(for: server).subtitle,
                        favoriteIconName: viewModel.favoriteIconName(for: server),
                        contextMenuItem: contextMenuItem(for: server)
                    )
                    
                }
            }
        }
        
        
    }
    
}
