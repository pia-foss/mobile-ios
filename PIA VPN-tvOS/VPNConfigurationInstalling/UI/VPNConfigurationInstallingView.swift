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
    
    init(viewModel: VPNConfigurationInstallingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            VStack {
                Text(L10n.Localizable.VpnPermission.Body.title)
                    .font(.title2)
                    .bold().padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                Text(L10n.Localizable.VpnPermission.Body.subtitle(L10n.Welcome.Purchase.continue))
                    .font(.headline)
                    .foregroundStyle(.gray)
            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            Spacer()
            VStack {
                Button {
                    viewModel.install()
                } label: {
                    Text(L10n.Welcome.Purchase.continue)
                }
                Text(L10n.Localizable.VpnPermission.Body.footer)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }.alert("PIA", isPresented: $viewModel.shouldShowErrorMessage, actions: {
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
