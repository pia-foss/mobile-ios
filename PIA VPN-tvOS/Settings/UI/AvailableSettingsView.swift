//
//  AvailableSettingsView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct AvailableSettingsView: View {
    @ObservedObject var viewModel: AvailableSettingsViewModel
    @FocusState var focusedSection: AvailableSettingsViewModel.Sections?
    
    var body: some View {
        HStack {
            availableSettingsList
            Spacer()
            Image.pia_settings_bg_image
                .frame(width: 840)
                .aspectRatio(contentMode: .fit)
        }
        .padding(.top, Spacing.screenTopPadding)
    }
    
    var availableSettingsList: some View {
        List {
            ForEach(viewModel.sections, id: \.self) { section in
                Button {
                    viewModel.navigate(to: section)
                } label: {
                    HStack {
                        Text(section.title)
                            .font(.system(size: 38, weight: .medium))
                            .foregroundColor(focusedSection == section ? .pia_on_primary : .pia_on_surface)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(focusedSection == section ? .pia_on_primary : .pia_on_surface)
                    }
                }
                .focused($focusedSection, equals: section)
                .buttonStyle(BasicButtonStyle())
                .buttonBorderShape(.roundedRectangle)
                .listRowBackground(
                    focusedSection == section ?
                    Color.pia_primary
                        .clipShape(RoundedRectangle(cornerSize: Spacing.listItemCornerSize)) :
                    Color.pia_surface_container_secondary
                        .clipShape(RoundedRectangle(cornerSize: Spacing.listItemCornerSize))
                )
                
            }
        }
        
    }
}

