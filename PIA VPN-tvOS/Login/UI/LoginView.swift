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
                    Text("Sign in to your account")
                        .font(.system(size: 36))
                    TextField("Username(p1234567)", text: $userName)
                    SecureField("Password", text: $password)
                    Button(action: {
                        viewModel.login(username: userName, password: password)
                    }, label: {
                        Text("LOGIN")
                    })
                }
            }
        }.alert("Error", isPresented: $viewModel.shouldShowErrorMessage, actions: {
            Button("OK") {}
        }, message: {
            if case .failed(let errorMessage, _) = viewModel.loginStatus, let errorMessage = errorMessage {
                Text(errorMessage)
            }
        })
    }
}
