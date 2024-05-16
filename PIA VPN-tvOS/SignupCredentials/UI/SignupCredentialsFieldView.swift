//
//  SignupCredentialsFieldView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 13/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupCredentialsFieldView: View {
    let title: String
    let subtitle: String
    var body: some View {
        ZStack(alignment: .leading) {
            Color.piaSurfaceContainerPrimary
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 38))
                    .foregroundStyle(.piaOnSurfaceContainerPrimary)
                Text(subtitle)
                    .font(.system(size: 38))
                    .foregroundStyle(.piaOnSurface)
            }
            .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 0))
        }
        .overlay(content: {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.pia_outline_variant_primary , lineWidth: 1)
        })
    }
}
