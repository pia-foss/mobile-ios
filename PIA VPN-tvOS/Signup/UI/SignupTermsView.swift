//
//  SignupTermsView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 16/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupTermsView: View {
    let url: URL
    let title: String
    let description: String
    let qrCodeMessage: String
    
    var body: some View {
        VStack(spacing: 100) {
            Text(title)
                .font(.system(size: 58, weight: .bold))
                .foregroundColor(.pia_on_surface)
            
            VStack(alignment: .leading, spacing: 60) {
               Text(description)
                    .font(.system(size: 29, weight: .medium))
                    .foregroundColor(.pia_on_surface)
                    .lineLimit(nil)
                privacyPolicyQRCodeSection
            }
            .frame(maxWidth: Spacing.contentViewMaxWidth)
        }
    }
    
    var privacyPolicyQRCodeSection: some View {
        HStack(alignment: .center, spacing: 40) {
            QRImageView(qrImageURL: url)
            Text(qrCodeMessage)
                .font(.system(size: 29, weight: .medium))
                .foregroundColor(.pia_on_surface)
                .lineLimit(nil)
        }
    }
}
