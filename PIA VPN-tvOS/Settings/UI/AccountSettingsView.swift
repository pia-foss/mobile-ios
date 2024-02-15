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
    @FocusState var logoutButtonFocused: Bool
    
    var body: some View {
        if viewModel.isLoading {
            LoginLoadingView()
        } else {
            accountSettingsSection
        }
    }
    
    var accountSettingsSection: some View {
        HStack {
            logOutButton
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
    
    var logOutButton: some View {
        List {
            Button {
                viewModel.logOutButtonWasTapped()
            } label: {
                HStack {
                    Text("Log Out")
                        .font(.system(size: 38, weight: .medium))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                        .foregroundColor(logoutButtonFocused ? .pia_on_primary : .pia_on_surface)
                    Spacer()
                }
               
            }
            .focused($logoutButtonFocused)
            .buttonStyle(BasicButtonStyle())
            .buttonBorderShape(.roundedRectangle)
            .listRowBackground(
                logoutButtonFocused ?
                Color.pia_primary
                    .clipShape(RoundedRectangle(cornerSize: Spacing.listItemCornerSize)) :
                Color.pia_surface_container_secondary
                    .clipShape(RoundedRectangle(cornerSize: Spacing.listItemCornerSize))
            )
        }
       

    }
}
