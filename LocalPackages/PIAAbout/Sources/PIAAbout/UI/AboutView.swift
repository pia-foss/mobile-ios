//
//  AboutView.swift
//  PIAAbout
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

public struct AboutView: View, ViewWithTitle {
    @StateObject private var store: AboutStore

    public var navigationTitle: String { L10n.Menu.Item.about }

    public init(header: String, dependencies: About.Dependencies) {
        _store = StateObject(wrappedValue: AboutStore(initialState: .init(header: header), dependencies: dependencies))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: PIASpacing.s16) {
                Text(store.state.header)
                    .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PIASpacing.s8)

                ForEach(store.state.components?.notices ?? [], id: \.name) { notice in
                    VStack(alignment: .leading, spacing: PIASpacing.s4) {
                        Text(notice.name).typography(.subtitle2, color: .pia.primary)
                        Text(notice.copyright).typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                        MonospacedText(notice.notice)
                    }
                    .aboutCard()
                }

                ForEach(store.state.components?.licenses ?? [], id: \.name) { license in
                    LicenseCard(
                        license: license,
                        text: store.state.licenseTexts[license.name],
                        isAvailable: !store.state.unavailableLicenses.contains(license.name)
                    )
                }
            }
            .padding(PIASpacing.s16)
        }
        .background(Color.pia.background.ignoresSafeArea())
        .onAppear { store.send(.onAppear) }
    }
}

private struct LicenseCard: View {
    let license: AboutComponents.License
    let text: String?
    let isAvailable: Bool

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s12) {
            HStack(alignment: .top, spacing: PIASpacing.s12) {
                VStack(alignment: .leading, spacing: PIASpacing.s4) {
                    Link(destination: license.licenseURL) {
                        Text(license.name).typography(.subtitle2, color: .pia.primary)
                    }
                    Text(license.copyright).typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isAvailable {
                    Button {
                        withAnimation { isExpanded.toggle() }
                    } label: {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .foregroundColor(.pia.primary)
                            .padding(PIASpacing.s4)
                    }
                    .accessibilityHint(L10n.About.Accessibility.Component.expand)
                }
            }

            if isExpanded && isAvailable {
                if let text {
                    MonospacedText(text)
                } else {
                    ProgressView().frame(maxWidth: .infinity)
                }
            }
        }
        .aboutCard()
    }
}

private struct MonospacedText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.pia.onSurfaceContainerSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
    }
}

extension View {
    fileprivate func aboutCard() -> some View {
        multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(PIASpacing.s16)
            .background(Color.pia.surfaceContainerPrimary)
            .clipShape(RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous))
    }
}

#Preview {
    AboutView(
        header: "Copyright © 2014-2026 Private Internet Access, Inc.\nVPN by Private Internet Access 4.0.0 (100)",
        dependencies: .init(
            loadComponents: {
                AboutComponents(
                    notices: [.init(name: "OpenVPN", copyright: "© 2002-2018 OpenVPN Inc.", notice: "OpenVPN is a registered trademark of OpenVPN Inc.")],
                    licenses: [
                        .init(name: "WireGuard", copyright: "Copyright (c) 2019 Jason A. Donenfeld.", licenseURL: URL(string: "https://www.wireguard.com")!),
                        .init(name: "OpenSSL", copyright: "Copyright (c) 1998-2018 The OpenSSL Project.", licenseURL: URL(string: "https://www.openssl.org")!)
                    ]
                )
            },
            fetchLicense: { url in url.host == "www.wireguard.com" ? "MIT License\n\nPermission is hereby granted..." : nil }
        )
    )
}
