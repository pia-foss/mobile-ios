//
//  AvailableSettingsView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI
import PIAAssetsTV

struct AvailableSettingsView: View {
    @ObservedObject var viewModel: AvailableSettingsViewModel
    
    @FocusState var focusedSection: AvailableSettingsViewModel.Sections?
    
    
    var body: some View {
        HStack {
            availableSettingsList
            Spacer()
            Asset.settingsBgImage.swiftUIImage
                .frame(width: 840)
                .aspectRatio(contentMode: .fit)
        }
        .padding(.top, Spacing.screenTopPadding)
        .onAppear {
            setFocusToDefault()
        }
    }
    
    var availableSettingsList: some View {
        List {
            ForEach(viewModel.sections, id: \.self) { section in
                SettingsButtonView(title: section.title, style: .rightChevron) {
                    viewModel.navigate(to: section)
                }
                .focused($focusedSection, equals: section)
            }
        }
        
    }
}


// MARK: - Default focus

extension AvailableSettingsView {
    private func setFocusToDefault() {
        focusedSection = .account
    }
}
