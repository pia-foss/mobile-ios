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
