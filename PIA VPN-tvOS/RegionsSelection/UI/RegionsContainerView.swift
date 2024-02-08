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
                            .font(.headline)
                            .padding(.leading, 26)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                    
                }
                .cornerRadius(4)
                .buttonStyle(.plain)
                .focused($focusedFilter, equals: menuItem)
                
            }
        }
    }
    
    
    var navigateToSearchScreenButton: some View {
        Button {
            viewModel.navigate(to: .search)
        } label: {
            HStack(alignment: .center) {
                Spacer()
                VStack {
                    Spacer()
                    Text(viewModel.searchButtonTitle)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 18)
                        .background(Color.pia_primary)
                        .cornerRadius(8)
                    Spacer()
                }.frame(height: 150)
                
                Spacer()
                
            }
            .frame(height: 150)
            .padding()
            
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(ButtonBorderShape.roundedRectangle)
    }
    
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                regionsFilterButtons
                VStack {
                    switch viewModel.selectedSection {
                    case .favorites:
                        RegionsSelectionFactory.makeFavoriteRegionsListView()
                    case .all:
                        RegionsSelectionFactory.makeAllRegionsListView()
                    case .search:
                        VStack {
                            navigateToSearchScreenButton
                            RegionsSelectionFactory.makePreviouslySearchedRegionsListView()
                                .padding(.top, 40)
                        }
                        
                    }
                }.frame(width: viewWidth * 0.7)
            }
            .onChange(of: focusedFilter) { _, newValue in
                guard let focusedMenuItem = newValue else { return }
                viewModel.selectedSection = focusedMenuItem
            }
        }
        .frame(width: viewWidth)
        .background(Color.pia_background)
    }
}

#Preview {
    RegionsContainerView(viewModel: RegionsSelectionFactory.makeRegionsContainerViewModel())
}
