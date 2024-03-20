//
//  HelpOptionsView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct HelpOptionsView: View {
    @ObservedObject var viewModel: HelpOptionsViewModel
    @FocusState var focusedSection: HelpOptionsViewModel.Sections?
    
    var body: some View {
        HStack {
            VStack(spacing: 20) {
                helpOptionsView
                contactSupportSection
            }
            Spacer()
            Image.pia_help_bg_image
                .frame(width: 840)
                .aspectRatio(contentMode: .fit)
        }
        .padding(.top, Spacing.screenTopPadding)
        .onAppear {
            setFocusToDefault()
        }
    }
    
    
    var helpOptionsView: some View {
        List {
            HStack {
                Text(viewModel.appInfoContent.title)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(.pia_on_surface)
                    .padding(.leading, Spacing.settingsHorizontalBigPadding)
                Spacer()
                Text(viewModel.appInfoContent.value)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(.pia_on_surface)
                    .padding(.trailing, Spacing.settingsButtonHorizontalPadding)
            }
            
            SettingsButtonView(title: viewModel.aboutSectionTitle, style: .rightChevron) {
                viewModel.aboutOptionsButtonWasTapped()
            }
            .focused($focusedSection, equals: .about)
            
            SettingsButtonView(
                title: viewModel.helpImproveSectionContent.title ,
                subtitle: viewModel.helpImproveSectionContent.subtitle,
                style: .rightText(content: viewModel.helpImproveSectionContent.value)) {
                viewModel.toggleHelpImprove()
            }
            .focused($focusedSection, equals: .helpImprove)
        }
    }

    var contactSupportSection: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading,  spacing: 10) {
                Text(viewModel.contactSupportTitle)
                    .font(.system(size: 38))
                    .foregroundColor(.pia_on_surface_container_secondary)
                QRImageView(qrImageURL: viewModel.contactSupportURL)
            }
            
            Text(viewModel.contactSupportDescription)
                .font(.system(size: 29, weight: .medium))
                .foregroundColor(.pia_on_surface)
                .lineLimit(nil)
        }
    }
    
}

// MARK: - Default focus

extension HelpOptionsView {
    private func setFocusToDefault() {
        focusedSection = .about
    }
}
