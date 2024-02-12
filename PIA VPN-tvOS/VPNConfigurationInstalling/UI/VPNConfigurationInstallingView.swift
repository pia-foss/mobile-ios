//
//  VPNConfigurationInstallingView.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 15/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct VPNConfigurationInstallingView: View {
    @ObservedObject private var viewModel: VPNConfigurationInstallingViewModel
    private let style: OnboardingComponentStytle
    
    init(viewModel: VPNConfigurationInstallingViewModel, style: OnboardingComponentStytle) {
        self.viewModel = viewModel
        self.style = style
    }
    
    var body: some View {
        OnboardingComponentView(viewModel: viewModel, style: style)
            .alert("PIA", isPresented: $viewModel.shouldShowErrorMessage, actions: {
            Button(L10n.Localizable.Global.ok) {
                Task {
                    viewModel.install()
                }
            }
        }, message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        })
    }
}
