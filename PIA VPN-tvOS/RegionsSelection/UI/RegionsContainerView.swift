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
    @FocusState var focusedFilter: RegionsContainerViewModel.RegionsNavigationItems?
    
    var regionsFilterButtons: some View {
        List {
            ForEach(viewModel.sideMenuItems, id: \.self) { menuItem in
                Button {
                    viewModel.navigate(to: menuItem)
                } label: {
                    HStack {
                        Text(menuItem.text)
                            .font(.system(size: 38, weight: .medium))
                            .foregroundColor(.pia_on_surface)
                            .padding(20)
                        Spacer()
                    }
                    .background(focusedFilter == menuItem ? Color.pia_surface_container_primary : Color.clear)
                    .cornerRadius(12)
                    
                }
                .cornerRadius(4)
                .buttonStyle(.borderless)
                .focused($focusedFilter, equals: menuItem)
                
            }
        }.listStyle(.plain)
    }
    

    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                regionsFilterButtons
                    .frame(width: viewWidth * 0.23)
                VStack {
                    switch viewModel.selectedSection {
                    case .favorites:
                        RegionsSelectionFactory.makeFavoriteRegionsListView()
                    case .all:
                        RegionsSelectionFactory.makeAllRegionsListView()
                    case .search:
                        VStack {
                            SearchControllerButton(
                                buttonAction: {
                                viewModel.navigate(to: .search)
                            }, 
                                buttonTitle: viewModel.searchButtonTitle
                            )
                            RegionsSelectionFactory.makePreviouslySearchedRegionsListView()
                                .padding(.top, 40)
                        }
                        
                    }
                }
            }
            .onChange(of: focusedFilter) { _, newValue in
                guard let focusedMenuItem = newValue else { return }
                viewModel.selectedSection = focusedMenuItem
            }
        }
    }
}

#Preview {
    RegionsContainerView(viewModel: RegionsSelectionFactory.makeRegionsContainerViewModel())
}
