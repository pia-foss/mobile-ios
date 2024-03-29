//
//  DedicatedIPView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 20/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct DedicatedIPView: View {
    @ObservedObject private var viewModel: DedicatedIPViewModel
    
    init(viewModel: DedicatedIPViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if !$viewModel.dedicatedIPStats.isEmpty {
                DedicatedIpDetailsView(dedicatedIPStats: viewModel.dedicatedIPStats) {
                    viewModel.removeDIP()
                }
                .withTopNavigationBar(title: L10n.Localizable.Menu.Item.settings, subtitle: L10n.Localizable.Settings.Dedicatedip.title2)
            } else {
                DedicatedIpActivateView(shouldShowErrorMessage: $viewModel.shouldShowErrorMessage) { token in
                    Task {
                        await viewModel.activateDIP(token: token)
                    }
                }
            }
        }.onAppear {
            viewModel.onAppear()
        }.alert(L10n.Localizable.Settings.Dedicatedip.Alert.Success.title, isPresented: $viewModel.showActivatedDialog, actions: {
            Button(L10n.Localizable.Settings.Dedicatedip.Alert.Success.button) {}
        }, message: {
            Text(L10n.Localizable.Settings.Dedicatedip.Alert.Success.message)
    })
    }
}
