//
//  ProtocolSelectionView.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIAAssetsTV
import SwiftUI

struct ProtocolSelectionView: View {
    @ObservedObject var viewModel: ProtocolSelectionViewModel

    @FocusState var focusedProtocol: TvOSVPNProtocol?

    var body: some View {
        HStack {
            protocolList
            Spacer()
            Asset.settingsBgImage.swiftUIImage
                .frame(width: 840)
                .aspectRatio(contentMode: .fit)
        }
        .padding(.top, Spacing.screenTopPadding)
        .onAppear {
            focusedProtocol = viewModel.selectedProtocol
        }
    }

    var protocolList: some View {
        List {
            ForEach(viewModel.availableProtocols) { vpnProtocol in
                SettingsButtonView(
                    title: vpnProtocol.title,
                    style: viewModel.isSelected(vpnProtocol) ? .rightText(content: "✓") : .none
                ) {
                    viewModel.select(vpnProtocol)
                }
                .focused($focusedProtocol, equals: vpnProtocol)
            }
        }
    }
}
