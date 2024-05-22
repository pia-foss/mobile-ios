//
//  LoginQRView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 29/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct LoginQRView: View {
    @Binding var expiresAt: String
    var qrCodeURL: URL?
    let loginAction: () -> Void
    let restorePurchasesAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 50) {
                VStack(alignment: .leading, spacing: 35) {
                    Text(L10n.Localizable.Tvos.Login.Qr.title)
                        .font(.system(size: 57))
                        .foregroundColor(.piaOnBackground)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack(spacing: 30) {
                    if let qrCodeURL = qrCodeURL {
                        QRImageView(qrImageURL: qrCodeURL)
                    }
                    
                    VStack(alignment: .leading, spacing: 25) {
                        Text(L10n.Localizable.Tvos.Login.Qr.description)
                            .font(.system(size: 29))
                            .foregroundColor(.piaOnSurfaceContainerSecondary)
                        
                        VStack(alignment: .leading) {
                            Text(L10n.Localizable.Tvos.Login.Qr.timer)
                                .font(.system(size: 29))
                                .foregroundColor(.piaOnSurfaceContainerSecondary)
                            Text(expiresAt)
                                .font(.system(size: 29))
                                .foregroundColor(.pia_on_warning_outline)
                        }
                    }
                }
                
                VStack {
                    ActionButton(
                        title: L10n.Localizable.Tvos.Login.Qr.Button.login,
                        action: { loginAction() }
                    )
                    .frame(width: 480, height: 66)
                    ActionButton(
                        title: L10n.Localizable.Tvos.Login.Qr.Button.restore,
                        action: { restorePurchasesAction() }
                    )
                    .frame(width: 480, height: 66)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 80, leading: 30, bottom: 0, trailing: 0))
            
            Image.signup_setup_screen
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
        }
    }
}
