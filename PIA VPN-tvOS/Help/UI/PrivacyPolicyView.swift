//
//  PrivacyPolicyView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/27/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct PrivacyPolicyView: View {
    
    let privacyPolicyURL: URL
    
    let privacyPolicyDescription = L10n.Localizable.HelpMenu.AboutSection.PrivacyPolicy.description
    let privacyPolicyQrCodeMessage = L10n.Localizable.HelpMenu.AboutSection.PrivacyPolicy.QrCode.message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 60) {
           Text(privacyPolicyDescription)
                .font(.system(size: 29, weight: .medium))
                .foregroundColor(.pia_on_surface)
                .lineLimit(nil)
            privacyPolicyQRCodeSection
        }
        .frame(maxWidth: Spacing.contentViewMaxWidth)
    }
    
    var privacyPolicyQRCodeSection: some View {
        HStack(alignment: .center, spacing: 40) {
            QRImageView(qrImageURL: privacyPolicyURL)
            Text(privacyPolicyQrCodeMessage)
                .font(.system(size: 29, weight: .medium))
                .foregroundColor(.pia_on_surface)
                .lineLimit(nil)
        }
    }
}
