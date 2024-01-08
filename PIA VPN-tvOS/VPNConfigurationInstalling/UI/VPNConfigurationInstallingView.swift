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
                Text("PIA needs access to your VPN profiles to secure your traffic.")
                    .font(.title2)
                    .bold().padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                Text("You’ll see a prompt for PIA VPN and need to allow access to VPN configurations.\nTo proceed tap on “OK”")
                    .font(.headline)
                    .foregroundStyle(.gray)
            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            Spacer()
            VStack {
                Button {
                    viewModel.install()
                } label: {
                    Text("Continue")
                }
                Text("We don’t monitor, filter or log any network activity.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }.alert("PIA", isPresented: $viewModel.shouldShowErrorMessage, actions: {
            Button("OK") {
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
