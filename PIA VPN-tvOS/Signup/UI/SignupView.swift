//
//  SignupView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 1/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupView: View {
    @StateObject var viewModel: SignupViewModel
    
    var body: some View {
        HStack {
            if viewModel.isLoading {
                SignupLoadingView()
            } else {
                VStack(alignment: .center, spacing: 60) {
                    
                    Image.onboarding_pia_brand
                    
                    Text(L10n.Localizable.Tvos.Signup.Subscription.title)
                        .font(.system(size: 76))
                        .foregroundColor(.piaOnBackground)
                        
                    Spacer()
                    
                    VStack {
                        Image.signup_screen.padding(EdgeInsets(top: 50, leading: 50, bottom: 50, trailing: 50))
                    }
                    .background(Color.piaSurfaceContainerPrimary)
                    .cornerRadius(20)
                }
                
                Divider()
                
                SignupSubscriptionView(viewModel: viewModel)
                
                
            }
        }.onAppear {
            viewModel.getproducts()
        }.alert("", isPresented: $viewModel.shouldShowErrorMessage, actions: {
            Button(L10n.Localizable.Global.ok) {}
        }, message: {
            Text(viewModel.errorMessage ?? L10n.Localizable.Tvos.Signup.Subscription.Error.Message.generic)
    })
    }
}
