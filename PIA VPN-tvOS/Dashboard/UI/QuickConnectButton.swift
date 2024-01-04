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
    
    var size: CGFloat = 65
    
    var body: some View {
        Button {
            viewModel.connectButtonDidTap()
        } label: {
            Image(viewModel.flagName)
                .resizable()
                .frame(width: size, height: size*0.75)
        }
        .buttonStyle(.card)
        .buttonBorderShape(.roundedRectangle(radius: 2))

    }
}

