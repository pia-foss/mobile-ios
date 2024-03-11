//
//  RegionsContainerView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/19/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct RegionsContainerView: View {
    
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
                            .foregroundColor(focusedFilter == menuItem ? .pia_on_primary : .pia_on_surface)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        Spacer()
                    }
                    .background(focusedFilter == menuItem ? Color.pia_primary :
                                    viewModel.selectedSection == menuItem ? Color.pia_surface_container_primary :    Color.clear)
                    .cornerRadius(12)
                    
                }
                .cornerRadius(4)
                .buttonStyle(BasicButtonStyle())
                .focused($focusedFilter, equals: menuItem)
                .disabled(viewModel.isRegionNavigationItemDisabled(menuItem, when: focusedFilter))
                
            }
        }
    }
    

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 40) {
                regionsFilterButtons
                    .frame(width: Spacing.regionsFilterSectionWidth)
                    .padding(.top, -10)
                VStack(alignment: .trailing) {
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
                .frame(minWidth: 1208)
            }
            .onChange(of: focusedFilter) { _, newValue in
                guard let focusedMenuItem = newValue else { return }
                viewModel.selectedSection = focusedMenuItem
            }
        }

    }
}


