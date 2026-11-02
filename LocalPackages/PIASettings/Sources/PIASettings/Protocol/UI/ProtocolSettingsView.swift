//
//  ProtocolSettingsView.swift
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

public struct ProtocolSettingsView: View, ViewWithTitle {
    @StateObject private var store: ProtocolSettingsStore

    public var navigationTitle: String { L10n.Settings.Section.protocols }

    public init(dependencies: ProtocolSettings.Dependencies) {
        _store = StateObject(
            wrappedValue: ProtocolSettingsStore(
                initialState: .init(
                    preferences: dependencies.loadPreferences(),
                    options: dependencies.loadOptions()
                ),
                dependencies: dependencies
            )
        )
    }

    public var body: some View {
        SettingsList {
            ForEach(store.state.rows, id: \.self) { row in
                view(for: row)
            }
        }
        .task { store.send(.onAppear) }
    }

    @ViewBuilder
    private func view(for row: ProtocolSettings.Row) -> some View {
        switch row {
        case .vpnProtocol:
            SettingsMenuRow(
                title: L10n.Settings.Connection.VpnProtocol.title,
                options: ProtocolSettings.VPNProtocol.allCases,
                selection: store.binding(\.preferences.vpnProtocol) { .vpnProtocolSelected($0) },
                label: \.title
            )
        case .transport:
            SettingsMenuRow(
                title: L10n.Settings.Connection.Transport.title,
                options: ProtocolSettings.Transport.allCases,
                selection: store.binding(\.preferences.transport) { .transportSelected($0) },
                label: \.title
            )
        case .remotePort(let isEnabled):
            SettingsMenuRow(
                title: L10n.Settings.Connection.RemotePort.title,
                options: store.state.remotePorts,
                selection: store.binding(\.preferences.remotePort) { .remotePortSelected($0) },
                label: { $0 == ProtocolSettings.automaticPort ? L10n.Global.automatic : "\($0)" }
            )
            .disabled(!isEnabled)
        case .dataEncryption(isEditable: true):
            SettingsMenuRow(
                title: L10n.Settings.Encryption.Cipher.title,
                options: store.state.options.ciphers,
                selection: store.binding(\.preferences.cipher) { .cipherSelected($0) },
                label: { $0 }
            )
        case .dataEncryption(isEditable: false):
            SettingsValueRow(title: L10n.Settings.Encryption.Cipher.title, value: store.state.dataEncryption)
        case .handshake:
            SettingsValueRow(title: L10n.Settings.Encryption.Handshake.title, value: store.state.handshake)
        case .smallPackets:
            SettingsToggleRow(
                title: L10n.Settings.Small.Packets.title,
                description: L10n.Settings.Small.Packets.description,
                isOn: store.binding(\.preferences.usesSmallPackets) { .smallPacketsToggled($0) }
            )
        }
    }
}

extension ProtocolSettings.VPNProtocol {
    fileprivate var title: String {
        switch self {
        case .automatic: L10n.Global.automatic
        case .wireGuard: "WireGuard®"
        case .openVPN: "OpenVPN"
        }
    }
}

extension ProtocolSettings.Transport {
    fileprivate var title: String {
        switch self {
        case .automatic: L10n.Global.automatic
        case .udp: "UDP"
        case .tcp: "TCP"
        }
    }
}
