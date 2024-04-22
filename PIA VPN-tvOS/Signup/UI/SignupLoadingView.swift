//
//  SignupLoadingView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupLoadingView: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 70) {
                Image.loading_pia_brand
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.74)
            }
        }
    }
}
