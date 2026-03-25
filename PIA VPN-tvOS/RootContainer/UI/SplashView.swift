//
//  SplashView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 8/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI
import PIAAssetsTV

struct SplashView: View {
    var body: some View {
        VStack(alignment: .center) {
            Asset.loadingPiaBrand.swiftUIImage
        }
    }
}

#Preview {
    SplashView()
}
