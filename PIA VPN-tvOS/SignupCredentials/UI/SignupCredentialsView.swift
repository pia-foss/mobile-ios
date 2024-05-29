//
//  SignupCredentialsView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 13/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupCredentialsView: View {
    let credentials: Credentials
    let action: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 60) {
                
                Image.onboarding_pia_brand
                
                Text(L10n.Localizable.Tvos.Signup.Credentials.title)
                    .font(.system(size: 76))
                    .foregroundStyle(.piaOnBackground)
                    
                Spacer()
                
                VStack {
                    Image.signup_credentials
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 50, leading: 60, bottom: 60, trailing: 60))
                }
                .background(Color.piaSurfaceContainerPrimary)
                .cornerRadius(20)
            }
            
            Divider()
            
            VStack(alignment: .center, spacing: 40) {
                VStack(spacing: 30) {
                    Text(L10n.Localizable.Tvos.Signup.Credentials.Details.title)
                        .font(.system(size: 57))
                        .bold()
                        .foregroundStyle(.piaOnBackground)
                    
                    Text(L10n.Localizable.Tvos.Signup.Credentials.Details.subtitle)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 31))
                        .foregroundStyle(.piaOnBackground)
                }
                
                VStack(alignment: .leading, spacing: 40) {
                    SignupCredentialsFieldView(title: L10n.Signup.Success.Username.caption,
                                               subtitle: credentials.username)
                    
                    SignupCredentialsFieldView(title: L10n.Signup.Success.Password.caption,
                                               subtitle: credentials.password)
                }
                .frame(height: 250)
                .padding(EdgeInsets(top: 20, leading: 30, bottom: 0, trailing: 30))
                
                ActionButton(title: L10n.Localizable.Tvos.Signup.Credentials.Details.button) {
                    action()
                }
                .frame(height: 66)
                .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
            }
        }
    }
}
