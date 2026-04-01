//
//  AccountSettingsView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct AccountSettingsView: View {
    @ObservedObject var viewModel: AccountSettingsViewModel
    
    let sectionsVerticalSpacing: CGFloat = 20
    
    var body: some View {
        if viewModel.isLoading {
            LoginLoadingView()
                .navigationBarHidden(true)
                .toolbar(.hidden)
        } else {
            accountSettingsSection
        }
    }
    
    func accountInfoTextView(with text: String) -> some View {
        Text(text)
            .font(.system(size: 38, weight: .medium))
            .foregroundColor(.pia_on_surface_container_primary)
    }
    
    var accountInfoSection: some View {
        VStack(spacing: sectionsVerticalSpacing) {
            HStack {
                accountInfoTextView(with: viewModel.usernameTitle)
                Spacer()
                accountInfoTextView(with:viewModel.usernameValue)
            }
            HStack {
                accountInfoTextView(with:viewModel.subscriptionTitle)
                Spacer()
                accountInfoTextView(with:viewModel.subscriptionValue)
            }
        }
    }
    
    var accountSettingsSection: some View {
        HStack {
            VStack(spacing: sectionsVerticalSpacing) {
                accountInfoSection
                ActionButton(title: viewModel.logOutButtonTitle, style: ActionButtonStyleType.leadingAligned.style) {
                    viewModel.logOutButtonWasTapped()
                }
                .frame(height: 66)
                .padding(.top, sectionsVerticalSpacing)
                Spacer()
            }
            
            Spacer()
            Image.pia_settings_bg_image
                .frame(width: 840)
                .aspectRatio(contentMode: .fit)
        }
        .padding(.top, Spacing.screenTopPadding)
        .alert(viewModel.logOutAlertTitle, isPresented: $viewModel.isLogOutAlertVisible) {
            Button(viewModel.logOutAlertCancelActionText, role: .cancel) { }
            Button(viewModel.logOutButtonTitle, role: .none) {
                viewModel.logOutConfirmationButtonWasTapped()
            }
        } message: {
            Text(viewModel.logOutAlertMesage)
        }
    }
    
}
