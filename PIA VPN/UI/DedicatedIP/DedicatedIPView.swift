//
//  DedicatedIPView.swift
//  PIA VPN
//
//  Created by Mario on 30/03/2026.
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
import PIALibrary
import PIALocalizations
import PIASwiftUI
import PIAUIKit
import SwiftUI
import UIKit

struct DedicatedIPView: View, ViewWithTitle {
    @ObservedObject private var viewModel: DedicatedIPViewModel
    @State private var isShowingRemoveAlert = false

    init(viewModel: DedicatedIPViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var navigationTitle: String { L10n.Dedicated.Ip.title }

    var body: some View {
        List {
            DipHeader(hasDedicatedIP: viewModel.dedicatedIp != nil, token: $viewModel.token) {
                Task {
                    await viewModel.activate()
                }
            }
            if let server = viewModel.dedicatedIp {
                ListSection(server: server, isShowingRemoveAlert: $isShowingRemoveAlert)
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
        .background(Color.pia.background)
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .alert(L10n.Dedicated.Ip.remove, isPresented: $isShowingRemoveAlert) {
            Button(L10n.Global.cancel, role: .cancel) {}
            Button(L10n.Global.remove, role: .destructive) {
                Task { await viewModel.deactivate() }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct DipHeader: View {
    let hasDedicatedIP: Bool
    @Binding var token: String
    let activate: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Dedicated.Ip.title)
                    .typography(.title1, color: .pia.onBackground)

                if hasDedicatedIP {
                    Text(L10n.Dedicated.Ip.Limit.title)
                } else {
                    Text(L10n.Dedicated.Ip.Activation.description)
                    TokenInput(token: $token, activate: activate)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.pia.surfaceContainerPrimary)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .typography(.body2, color: .pia.onSurfaceContainerPrimary)
        }
    }
}

private struct ListSection: View {
    let server: ServerType
    @Binding var isShowingRemoveAlert: Bool

    var body: some View {
        Section {
            DipRow(server: server)
                .swipeActions(edge: .trailing) {
                    RemoveButton(isShowingRemoveAlert: $isShowingRemoveAlert)
                }
                .contextMenu {
                    RemoveButton(isShowingRemoveAlert: $isShowingRemoveAlert)
                }
        } header: {
            HStack {
                Text(L10n.Dedicated.Ip.Plural.title.uppercased())
                    .typography(.subtitle3, color: .pia.primary)
                Spacer()
            }
            .textCase(nil)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.pia.background)
            .frame(maxWidth: .infinity, alignment: .leading)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
    }
}

private struct TokenInput: View {
    @FocusState private var isTokenFieldFocused: Bool
    @Binding var token: String
    let activate: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField(L10n.Dedicated.Ip.Token.Textfield.placeholder, text: $token)
                .typography(.body1)
                .focused($isTokenFieldFocused)
                .padding(.leading, 6)
                .accessibilityLabel(L10n.Dedicated.Ip.Token.Textfield.accessibility)
                .onSubmit(activate)

            Button(L10n.Dedicated.Ip.Activate.Button.title, action: activate)
                .primaryButton(radius: 6)
        }
        .padding(6)
        .modifier(TextFieldModifier(isFocused: isTokenFieldFocused, focusedOutline: .pia.primary))
    }
}

private struct RemoveButton: View {
    @Binding var isShowingRemoveAlert: Bool

    var body: some View {
        Button(role: .destructive) {
            isShowingRemoveAlert = true
        } label: {
            Label(L10n.Global.remove, systemImage: "trash")
        }
    }
}

private struct DipRow: View {
    let server: any ServerType

    var body: some View {
        HStack(spacing: 12) {
            ServerFlagButton(
                name: server.name,
                country: server.country.lowercased(),
                isDip: server.dipToken != nil,
            )

            Text(server.name)
                .typography(.body1)

            Spacer()

            if let ip = server.dipIKEv2IP {
                Text(ip)
                    .typography(.body2, color: .pia.onSurfaceContainerPrimary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.pia.surfaceContainerPrimary)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

private struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(2)
        }
    }
}
