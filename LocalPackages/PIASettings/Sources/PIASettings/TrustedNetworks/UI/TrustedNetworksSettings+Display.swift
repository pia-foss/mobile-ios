//
//  TrustedNetworksSettings+Display.swift
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

import PIAAssetsMobile
import PIADesignSystem
import PIALocalizations
import SwiftUI

typealias NMTAsset = Asset.Piax.Nmt

extension TrustedNetworksSettings.Network {
    var title: String {
        switch self {
        case .secureWiFi: L10n.Network.Management.Tool.Secure.wifi
        case .openWiFi: L10n.Network.Management.Tool.Open.wifi
        case .mobileData: L10n.Network.Management.Tool.Mobile.data
        case .custom(let ssid): ssid
        }
    }

    var ssid: String? {
        guard case .custom(let ssid) = self else { return nil }
        return ssid
    }
}

extension TrustedNetworksSettings.Behavior {
    var title: String {
        switch self {
        case .alwaysConnect: L10n.Network.Management.Tool.Always.connect
        case .alwaysDisconnect: L10n.Network.Management.Tool.Always.disconnect
        case .retainState: L10n.Network.Management.Tool.Retain.state
        }
    }

    var menuIcon: Image {
        switch self {
        case .alwaysConnect: NMTAsset.iconNmtConnect.swiftUIImage
        case .alwaysDisconnect: NMTAsset.iconDisconnect.swiftUIImage
        case .retainState: NMTAsset.iconRetain.swiftUIImage
        }
    }

    // The NMT colours match the tint baked into the network icons, so they stay instead of design tokens
    var statusColor: Color {
        switch self {
        case .alwaysConnect: Color(uiColor: .piaNMTGreen)
        case .alwaysDisconnect: Color(uiColor: .piaNMTRed)
        case .retainState: Color(uiColor: .piaNMTBlue)
        }
    }
}

extension TrustedNetworksSettings.Rule {
    var icon: Image {
        let asset: ImageAsset =
            switch (network, behavior) {
            case (.secureWiFi, .alwaysConnect): NMTAsset.iconSecureWifiConnect
            case (.secureWiFi, .alwaysDisconnect): NMTAsset.iconSecureWifiDisconnect
            case (.secureWiFi, .retainState): NMTAsset.iconSecureWifiRetain
            case (.openWiFi, .alwaysConnect): NMTAsset.iconOpenWifiConnect
            case (.openWiFi, .alwaysDisconnect): NMTAsset.iconOpenWifiDisconnect
            case (.openWiFi, .retainState): NMTAsset.iconOpenWifiRetain
            case (.mobileData, .alwaysConnect): NMTAsset.iconMobileDataConnect
            case (.mobileData, .alwaysDisconnect): NMTAsset.iconMobileDataDisconnect
            case (.mobileData, .retainState): NMTAsset.iconMobileDataRetain
            case (.custom, .alwaysConnect): NMTAsset.iconCustomWifiConnect
            case (.custom, .alwaysDisconnect): NMTAsset.iconCustomWifiDisconnect
            case (.custom, .retainState): NMTAsset.iconCustomWifiRetain
            }
        return asset.swiftUIImage
    }
}

/// The description shown above the content, under the navigation bar title
struct NMTDescription: View {
    let text: String

    var body: some View {
        Text(text)
            .typography(.body2, color: .pia.onSurfaceContainerSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, PIASpacing.s20)
            .padding(.top, PIASpacing.s16)
            .padding(.bottom, PIASpacing.s16)
    }
}

/// The rule options offered for a network, shared by the rule cards and the custom network rows
struct NetworkBehaviorMenuItems: View {
    let onSelect: (TrustedNetworksSettings.Behavior) -> Void

    var body: some View {
        ForEach(TrustedNetworksSettings.Behavior.allCases, id: \.self) { behavior in
            Button {
                onSelect(behavior)
            } label: {
                Label {
                    Text(behavior.title)
                } icon: {
                    behavior.menuIcon.renderingMode(.template)
                }
            }
        }
    }
}
