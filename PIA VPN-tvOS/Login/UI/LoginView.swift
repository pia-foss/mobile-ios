//
//  LoginView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var focused: Bool
    
    @ObservedObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.loginStatus == .isLogging {
                LoginLoadingView()
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 60) {
                        Image.onboarding_pia_brand
                        Text(L10n.Localizable.Tvos.Login.title)
                            .font(.system(size: 57))
                            .bold()
                            .fixedSize(horizontal: false, vertical: true)
                            
                        FormTextFieldsView(username: $username, password: $password) {
                            viewModel.login(username: username, password: password)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 80, leading: 30, bottom: 0, trailing: 0))
                        
                    Image.onboarding_signin_world
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                }.alert(L10n.Localizable.Global.error, isPresented: $viewModel.shouldShowErrorMessage, actions: {
                    Button(L10n.Localizable.Global.ok) {}
                }, message: {
                    if case .failed(let errorMessage, _) = viewModel.loginStatus, let errorMessage = errorMessage {
                        Text(errorMessage)
                    }
                })
            }
            
        }
    }
}
