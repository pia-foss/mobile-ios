//
//  HelpSettingsView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI
import PIAAssetsTV

struct AboutOptionsView: View {
    @ObservedObject var viewModel: AboutOptionsViewModel
    
    var body: some View {
        HStack {
            helpSectionsView
            Spacer()
            Asset.helpBgImage.swiftUIImage
                .frame(width: 840)
                .aspectRatio(contentMode: .fit)
        }
        .padding(.top, Spacing.screenTopPadding)
    }
    
    var helpSectionsView: some View {
        List {
            ForEach(viewModel.sections, id: \.self) { section in
                SettingsButtonView(title: section.title, style: .rightChevron) {
                    viewModel.navigate(to: section)
                }
            }
        }
    }
}
