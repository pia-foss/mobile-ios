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
            Text("Sign in to your account")
                .font(.system(size: 36))
            TextField("Username(p1234567)", text: $userName)
            TextField("Password", text: $password)
            Button(action: {
                Task {
                    await viewModel.login(username: userName, password: password)
                }
            }, label: {
                Text("LOGIN")
            })
        }
    }
}
