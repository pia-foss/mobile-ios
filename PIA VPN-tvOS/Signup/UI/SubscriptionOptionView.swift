//
//  SubscriptionOptionView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 1/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SubscriptionOptionView: View {
    let viewModel: SubscriptionOptionViewModel
    @FocusState private var isFocus: Bool
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            Color.piaSurfaceContainerPrimary
            Button(action: {
                action()
            }) {
                VStack {
                    HStack {
                        Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(isFocus ? Color.pia_primary : Color.pia_on_surface_container_primary)
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.optionString)
                                .font(.system(size: 48))
                                .foregroundColor(Color.pia_on_surface_container_primary)
                            
                            VStack(spacing: 5) {
                                Text(viewModel.price)
                                    .font(.system(size: 38))
                                    .foregroundColor(Color.pia_on_surface_container_primary)
                                if let freeTrial = viewModel.freeTrial {
                                    Text(freeTrial)
                                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                        .background(.yellow)
                                        .font(.system(size: 23))
                                        .foregroundColor(Color.pia_grey_grey20)
                                        .cornerRadius(5)
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                }
                
            }.overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocus ? Color.piaPrimary : Color.pia_outline_variant_primary , lineWidth: 1)
            )
            .buttonStyle(.borderless)
            .focused($isFocus)
        }
    }
}
