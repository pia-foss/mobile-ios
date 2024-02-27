//
//  QRImageView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct QRImageView: View {
    private let qrImageURL: URL
    
    init(qrImageURL: URL) {
        self.qrImageURL = qrImageURL
    }
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 300, height: 300)
            .background(
                Image.asQRCode(url: qrImageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipped()
            )
    }
}
