//
//  CustomDNSSettingsView.swift
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

public struct CustomDNSSettingsView: View, ViewWithTitle {
    @StateObject private var store: CustomDNSSettingsStore

    public var navigationTitle: String { L10n.Settings.Dns.Custom.dns }

    public init(servers: [String], dependencies: CustomDNSSettings.Dependencies) {
        _store = StateObject(
            wrappedValue: CustomDNSSettingsStore(
                initialState: .init(servers: servers),
                dependencies: dependencies
            )
        )
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: PIASpacing.s16) {
                Group {
                    PIATextField(
                        L10n.Settings.Dns.primaryDNS,
                        placeholder: L10n.Global.required,
                        text: store.binding(\.primary) { .primaryChanged($0) }
                    )
                    PIATextField(
                        L10n.Settings.Dns.secondaryDNS,
                        placeholder: L10n.Global.optional,
                        text: store.binding(\.secondary) { .secondaryChanged($0) }
                    )
                }
                .keyboardType(.numbersAndPunctuation)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

                Button {
                    store.send(.updateTapped)
                } label: {
                    Text(L10n.Global.update)
                        .frame(maxWidth: .infinity)
                }
                .primaryButton()
                .padding(.top, PIASpacing.s8)

                if store.state.isClearable {
                    Button(role: .destructive) {
                        store.send(.clearTapped)
                    } label: {
                        Text(L10n.Settings.Dns.Alert.Clear.title)
                            .typography(.button1, color: .pia.error)
                            .frame(maxWidth: .infinity)
                            .padding(13)
                    }
                }
            }
            .padding(PIASpacing.s16)
        }
        .background(Color.pia.background.ignoresSafeArea())
        .alert(
            store.state.alert?.title ?? "",
            isPresented: store.binding(\.isAlertPresented) { _ in .alertDismissed },
            presenting: store.state.alert,
            actions: alertActions,
            message: { Text($0.message) }
        )
    }

    @ViewBuilder
    private func alertActions(_ alert: CustomDNSSettings.Alert) -> some View {
        switch alert {
        case .clearConfirmation:
            Button(L10n.Global.ok, role: .destructive) {
                store.send(.clearConfirmed)
            }
            Button(L10n.Global.cancel, role: .cancel) {}
        case .primaryMandatory, .primaryInvalid, .secondaryInvalid:
            Button(L10n.Global.ok, role: .cancel) {}
        }
    }
}

extension CustomDNSSettings.Alert {
    fileprivate var title: String {
        switch self {
        case .clearConfirmation: L10n.Settings.Dns.Alert.Clear.title
        case .primaryMandatory, .primaryInvalid, .secondaryInvalid: L10n.Settings.Dns.Custom.dns
        }
    }

    fileprivate var message: String {
        switch self {
        case .primaryMandatory: L10n.Settings.Dns.Validation.Primary.mandatory
        case .primaryInvalid: L10n.Settings.Dns.Validation.Primary.invalid
        case .secondaryInvalid: L10n.Settings.Dns.Validation.Secondary.invalid
        case .clearConfirmation: L10n.Settings.Dns.Alert.Clear.message
        }
    }
}

#Preview {
    CustomDNSSettingsView(
        servers: ["1.1.1.1", "8.8.8.8"],
        dependencies: .init(save: { _ in }, clear: {}, dismiss: {})
    )
}
