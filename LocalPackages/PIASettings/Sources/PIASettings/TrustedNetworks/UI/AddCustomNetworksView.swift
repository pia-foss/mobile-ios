//
//  AddCustomNetworksView.swift
//  PIASettings
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

public struct AddCustomNetworksView: View, ViewWithTitle {
    @ObservedObject private var store: TrustedNetworksSettingsStore

    public var navigationTitle: String { L10n.Network.Management.Tool.Add.rule }

    public init(store: TrustedNetworksSettingsStore) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                NMTDescription(
                    text: L10n.Network.Management.Tool.Choose.wifi + L10n.Settings.Hotspothelper.Available.help
                )

                LazyVStack(spacing: 1) {
                    ForEach(store.state.availableNetworks, id: \.self) { ssid in
                        Menu {
                            NetworkBehaviorMenuItems { store.send(.customNetworkSelected(ssid: ssid, $0)) }
                        } label: {
                            row(ssid)
                        }
                    }
                }
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
        .task { store.send(.addNetworkAppeared) }
    }

    private func row(_ ssid: String) -> some View {
        HStack(spacing: PIASpacing.s20) {
            NMTAsset.iconNmtWifi.swiftUIImage
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.pia.onSurfaceContainerSecondary)
                .accessibilityHidden(true)
            Text(ssid)
                .typography(.body1, color: .pia.onSurfaceContainerSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, PIASpacing.s20)
        .frame(height: 44)
        .background(Color.pia.surfaceContainerPrimary)
        .contentShape(Rectangle())
    }
}

#Preview {
    AddCustomNetworksView(store: .preview)
}
