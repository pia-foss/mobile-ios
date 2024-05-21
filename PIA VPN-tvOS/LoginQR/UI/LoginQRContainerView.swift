//
//  LoginQRContainerView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct LoginQRContainerView: View {
    @StateObject var viewModel: LoginQRViewModel
    
    var body: some View {
        VStack {
            if viewModel.state == .expired {
                LoginQRExpiredView(qrImageURL: viewModel.qrCodeURL) {
                    viewModel.generateQRCode()
                } loginAction: {
                    viewModel.navigateToRoute()
                }
            } else if viewModel.state == .loading {
                VStack {
                    VStack(alignment: .center) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.74)
                    }
                }
            } else {
                LoginQRView(expiresAt: $viewModel.expiresAt, qrCodeURL: viewModel.qrCodeURL) {
                    viewModel.navigateToRoute()
                }
            }
        }.onAppear {
            viewModel.generateQRCode()
        }.alert("", isPresented: $viewModel.shouldShowErrorMessage, actions: {
            Button(L10n.Localizable.Global.ok) {}
        }, message: {
            Text(L10n.Localizable.Tvos.Signup.Subscription.Error.Message.generic)
        })
    }
}
