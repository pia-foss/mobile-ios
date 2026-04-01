//
//  View+Extensions.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

extension View {
    func glow(color: Color = .red, radius: CGFloat = 20, opacity: CGFloat = 0.4) -> some View {
        self
            .shadow(color: color.opacity(opacity), radius: radius / 3)
            .shadow(color: color.opacity(opacity), radius: radius)
            
    }
}

extension Image {
    static func asQRCode(url: URL) -> Image {
        guard let ciImage = url.asQRCode(),
              let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
        else {
            return Image(uiImage: UIImage())
        }
        return Image(uiImage: UIImage(cgImage: cgImage))
    }
}
