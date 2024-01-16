//
//  LoginView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var userName: String = ""
    @State private var password: String = ""
    
    @ObservedObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                if viewModel.loginStatus == .isLogging {
                    ProgressView().progressViewStyle(.circular)
                }
                VStack {
                    Text(L10n.Welcome.Login.title)
                        .font(.system(size: 36))
                    TextField(L10n.Welcome.Login.Username.placeholder, text: $userName)
                    SecureField(L10n.Welcome.Login.Password.placeholder, text: $password)
                    Button(action: {
                        viewModel.login(username: userName, password: password)
                    }, label: {
                        Text(L10n.Welcome.Purchase.Login.button)
                    })
                }
            }
        }.alert(L10n.Localizable.Global.error, isPresented: $viewModel.shouldShowErrorMessage, actions: {
            Button(L10n.Localizable.Global.ok) {}
        }, message: {
            if case .failed(let errorMessage, _) = viewModel.loginStatus, let errorMessage = errorMessage {
                Text(errorMessage)
            }
        })
    }
}
