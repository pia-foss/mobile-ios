//
//  PIAToggleButton.swift
//  PIA VPN
//
//  Created by Mario on 05/08/2026.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIAAssetsWidget
import PIALibrary
import SwiftUI

internal struct PIAToggleButton: View {
    internal let size: CGFloat
    internal let isConnected: Bool

    var body: some View {
        if #available(iOS 17.0, *) {
            Button(intent: PIAVPNToggleIntent()) {
                buttonContent
            }
            .buttonStyle(.plain)
        } else {
            Link(destination: URL(string: AppConstants.Widget.connect)!) {
                buttonContent
            }
        }
    }

    private var buttonContent: some View {
        PIACircleImageView(
            size: size,
            image: isConnected
                ? Asset.connectedButton.swiftUIImage
                : Asset.disconnectedButton.swiftUIImage
        )
    }
}
