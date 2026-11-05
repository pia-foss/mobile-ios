//
//  NetworkSettingsView.swift
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

public struct NetworkSettingsView: View, ViewWithTitle {
    @StateObject private var store: NetworkSettingsStore

    public var navigationTitle: String { L10n.Settings.Section.network }

    public init(dependencies: NetworkSettings.Dependencies) {
        _store = StateObject(
            wrappedValue: NetworkSettingsStore(
                initialState: .init(
                    preferences: dependencies.loadPreferences(),
                    isEditable: dependencies.isEditable()
                ),
                dependencies: dependencies
            )
        )
    }

    public var body: some View {
        SettingsList {
            SettingsMenuRow(
                title: "DNS",
                options: store.state.dnsOptions,
                selection: store.binding(\.preferences.dns) { .dnsSelected($0) },
                label: \.title
            )
            SettingsNavigationRow(
                title: L10n.Settings.Dns.Custom.dns,
                value: store.state.customDNSValue
            ) {
                store.send(.customDNSTapped)
            }
        }
        .disabled(!store.state.isEditable)
        .task { store.send(.onAppear) }
        .alert(
            L10n.Settings.Dns.Custom.dns,
            isPresented: store.binding(\.isCustomDNSWarningPresented) { _ in .customDNSWarningDismissed },
            actions: {
                Button(L10n.Global.ok) {
                    store.send(.customDNSWarningConfirmed)
                }
                Button(L10n.Global.cancel, role: .cancel) {}
            },
            message: {
                Text(L10n.Settings.Dns.Alert.Create.message)
            }
        )
    }
}

extension NetworkSettings.DNS {
    fileprivate var title: String {
        switch self {
        case .preset(let name): name
        case .custom: L10n.Settings.Dns.custom
        }
    }
}

#Preview {
    NetworkSettingsView(
        dependencies: .init(
            loadPreferences: { .init(presets: ["PIA DNS"], customServers: ["1.1.1.1", "8.8.8.8"], dns: .custom) },
            isEditable: { true },
            preferencesChanges: { AsyncStream { $0.finish() } },
            setDNS: { _ in },
            showCustomDNS: {},
        )
    )
}
