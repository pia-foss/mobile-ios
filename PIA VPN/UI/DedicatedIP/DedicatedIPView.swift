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
    @State private var showDeleteAlert = false
    @FocusState private var isTokenFieldFocused: Bool

    init(viewModel: DedicatedIPViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var navigationTitle: String { L10n.Dedicated.Ip.title }

    var body: some View {
        List {
            headerListRow
            if viewModel.dedicatedIp != nil {
                dipListSection
            }
        }
        .listStyle(.plain)
        .background(Color.pia.background)
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .alert(L10n.Dedicated.Ip.remove, isPresented: $showDeleteAlert) {
            Button(L10n.Global.cancel, role: .cancel) {}
            Button(L10n.Global.ok, role: .destructive) {
                Task { await viewModel.deactivate() }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header row

    private var headerListRow: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Dedicated.Ip.title)
                    .typography(.title1, color: .pia.onBackground)

                if viewModel.dedicatedIp == nil {
                    Text(L10n.Dedicated.Ip.Activation.description)
                    tokenInputView

                } else {
                    Text(L10n.Dedicated.Ip.Limit.title)
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

    // MARK: - Token input

    private var tokenInputView: some View {
        HStack(spacing: 8) {
            TextField(L10n.Dedicated.Ip.Token.Textfield.placeholder, text: $viewModel.token)
                .typography(.body1)
                .focused($isTokenFieldFocused)
                .padding(.leading, 6)
                .accessibilityLabel(L10n.Dedicated.Ip.Token.Textfield.accessibility)
                .onSubmit {
                    Task { await viewModel.activate() }
                }

            Button(L10n.Dedicated.Ip.Activate.Button.title) {
                Task { await viewModel.activate() }
            }
            .buttonStyle(PIAGreenButtonStyle())
        }
        .padding(6)
        .background(Color.pia.surfaceContainerPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isTokenFieldFocused ? Color.pia.primary : Color.pia.outline,
                    lineWidth: 1
                )
        )
    }

    // MARK: - DIP list section

    private var dipListSection: some View {
        Section {
            if let server = viewModel.dedicatedIp {
                dipRow(server)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            // TODO: delete
                            Label(L10n.Global.disable, systemImage: "trash")
                        }
                    }
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

    // MARK: - DIP row

    private func dipRow(_ server: ServerType) -> some View {
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

    // MARK: - Loading

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(2)
        }
    }
}

// MARK: - Button Style

private struct PIAGreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typography(.button1, color: .white)
            .padding(13)
            .background(Color.pia.primary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
