//
//  ExpiredAccountView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 20/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct ExpiredAccountView: View {
    var viewModel: ExpiredAccountViewModel
    
    var body: some View {
        if viewModel.isLoading {
            LoginLoadingView()
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 50) {
                    VStack(alignment: .leading, spacing: 35) {
                        HStack(spacing: 0) {
                            Text(viewModel.title1)
                                .font(.system(size: 57))
                                .foregroundColor(.piaOnBackground)
                                .bold()
                            
                            if let title2 = viewModel.title2 {
                                Text(title2)
                                    .font(.system(size: 57))
                                    .foregroundColor(.piaError)
                                    .bold()
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        Text(viewModel.subtitle)
                            .font(.system(size: 31))
                            .foregroundColor(.piaOnSurfaceContainerSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack(spacing: 30) {
                        if let qrCodeURL = viewModel.qrCodeURL {
                            QRImageView(qrImageURL: qrCodeURL)
                        }
                        
                        VStack(alignment: .leading, spacing: 35) {
                            ForEach(viewModel.qrTitle, id: \.self) { title in
                                Text(title)
                                    .font(.system(size: 29))
                                    .foregroundColor(.piaOnSurfaceContainerSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                    
                    VStack {
                        ActionButton(
                            title: L10n.Localizable.Tvos.Signin.Expired.Button.signout,
                            action: { viewModel.logout() }
                        )
                        .frame(width: 510, height: 66)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                
                Image.signup_setup_screen
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing)
            }
        }
    }
}

