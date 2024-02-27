//
//  SignupView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupView: View {
    private let items: [String]
    private let signUpURL: URL
    
    init(signUpURL: URL) {
        self.signUpURL = signUpURL
        self.items = [
            L10n.Localizable.Tvos.Signup.item1,
            L10n.Localizable.Tvos.Signup.item2,
            L10n.Localizable.Tvos.Signup.item3
        ]
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 50) {
                Image.onboarding_pia_brand
                
                VStack(alignment: .leading, spacing: 35) {
                    Text(L10n.Localizable.Tvos.Signup.title)
                        .font(.system(size: 57))
                        .foregroundColor(.piaOnBackground)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(items, id: \.self) { item in
                            Text("• " + item)
                                .font(.system(size: 31))
                                .foregroundColor(.piaOnSurfaceContainerSecondary)
                        }
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    
                    Text(L10n.Localizable.Tvos.Signup.cta)
                        .font(.system(size: 31))
                        .foregroundColor(.piaOnSurfaceContainerSecondary)
                }
                
                QRImageView(qrImageURL: signUpURL)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 80, leading: 30, bottom: 0, trailing: 0))
                
            Image.signup_setup_screen
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
        }
    }
}

