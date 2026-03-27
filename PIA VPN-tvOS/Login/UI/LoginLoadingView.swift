//
//  LoginLoadingView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIAAssetsTV
import SwiftUI

struct LoginLoadingView: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 70) {
                Asset.loadingPiaBrand.swiftUIImage
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.74)
            }
        }
    }
}
