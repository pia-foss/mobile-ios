//
//  QuickConnectButton.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 12/26/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct QuickConnectButton: View {
    @ObservedObject var viewModel: QuickConnectButtonViewModel
    @FocusState var isButtonFocused: Bool
    
    var size: CGFloat = 80
    
    var body: some View {
        Button {
            viewModel.connectButtonDidTap()
        } label: {
            VStack(spacing: 8) {
                Image(viewModel.flagName)
                    .resizable()
                    .frame(width: size, height: size)
                Text(viewModel.titleText)
                    .font(.system(size: 29, weight: .medium))
                    .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface)
                    .lineLimit(nil)
            }
            .padding(24)
            
        }
        .frame(width: 160)
        .background(isButtonFocused ? Color.pia_primary : Color.pia_surface_container_primary)
        .clipShape(RoundedRectangle(cornerSize: Spacing.tileCornerSize))
        .focused($isButtonFocused)
        .buttonStyle(BasicButtonStyle())
        .buttonBorderShape(.roundedRectangle(radius: Spacing.tileBorderRadius))

    }
}

