//
//  LoginQRExpiredView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct LoginQRExpiredView: View {
    private let qrImageURL: URL
    private let generateQRCodeAction: () -> Void
    private let loginAction: () -> Void
    
    init(qrImageURL: URL, generateQRCodeAction: @escaping () -> Void, loginAction: @escaping () -> Void) {
        self.qrImageURL = qrImageURL
        self.generateQRCodeAction = generateQRCodeAction
        self.loginAction = loginAction
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 60) {
                VStack(alignment: .leading, spacing: 25) {
                    Text(L10n.Localizable.Tvos.Login.Qr.Expired.title)
                        .font(.system(size: 57))
                        .foregroundColor(.piaOnBackground)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(L10n.Localizable.Tvos.Login.Qr.Expired.description)
                        .font(.system(size: 31))
                        .foregroundColor(.piaOnSurfaceContainerSecondary)
                }
                
                ZStack(alignment: .center) {
                    QRImageView(qrImageURL: qrImageURL)
                        .opacity(0.04)
                    
                    ActionButton(
                        title: L10n.Localizable.Tvos.Login.Qr.Expired.Button.generate,
                        action: { generateQRCodeAction() }
                    )
                    .frame(height: 66)
                    .padding()
                }.frame(width: 300, height: 300)
                
                VStack {
                    ActionButton(
                        title: L10n.Localizable.Tvos.Login.Qr.Button.login,
                        action: { loginAction() }
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
