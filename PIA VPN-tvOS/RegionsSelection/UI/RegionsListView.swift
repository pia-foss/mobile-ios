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
    let viewWidth = UIScreen.main.bounds.width
    let viewHeight = UIScreen.main.bounds.height
    
    let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 250))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(viewModel.servers, id: \.identifier) { server in
                    Button {
                        viewModel.didSelectRegionServer(server)
                    } label: {
                        VStack {
                            Image("flag-\(server.country.lowercased())")
                                .padding()
                            Text(server.name)
                                .font(.subheadline)
                        }
                        
                    }

                }
            }
        }
        .frame(width: viewWidth - 50, height: viewHeight - 100)
        
    }
}

#Preview {
    RegionsListView(viewModel: RegionsSelectionFactory.makeRegionsListViewModel())
}
