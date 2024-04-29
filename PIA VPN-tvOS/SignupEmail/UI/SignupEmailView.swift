//
//  SignupEmailView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 26/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupEmailView: View {
    @State private var email = ""
    @StateObject var viewModel: SignupEmailViewModel
    
    var body: some View {
        if viewModel.isLoading {
            SignupLoadingView()
        } else {
            VStack {
                VStack {
                    VStack(spacing: 20) {
                        Text(L10n.Welcome.Purchase.Confirm.Form.email)
                            .font(.system(size: 76))
                            .foregroundStyle(.piaOnSurface)
                            .bold()
                        
                        Text(L10n.Welcome.Purchase.Email.why)
                            .font(.system(size: 29))
                            .foregroundStyle(.piaOnSurfaceContainerSecondary)
                            .multilineTextAlignment(.center)
                    }.padding(EdgeInsets(top: 80, leading: 0, bottom: 0, trailing: 0))
                    
                    TextField(
                        L10n.Welcome.Purchase.Email.placeholder,
                        text: $email,
                        prompt: Text(L10n.Welcome.Purchase.Email.placeholder)
                    )
                    .textFieldStyle(TextFieldStyleModifier())
                    .frame(width: 600, height: 50)
                    .padding(EdgeInsets(top: 100, leading: 0, bottom: 100, trailing: 0))
                    
                    ActionButton(title: L10n.Welcome.Purchase.submit) {
                        viewModel.signup(email: email)
                    }
                    .frame(width: 510, height: 66)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .alert("", isPresented: $viewModel.shouldShowErrorMessage, actions: {
                    Button(L10n.Localizable.Global.ok) {}
                }, message: {
                    Text(viewModel.errorMessage ?? "something wrong")
            })
        }
    }
}
