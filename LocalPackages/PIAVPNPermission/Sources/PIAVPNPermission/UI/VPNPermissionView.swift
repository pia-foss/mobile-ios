//
//  VPNPermissionView.swift
//  PIAVPNPermission
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
import PIASwiftUI
import SwiftUI

/// Asks for the VPN configuration permission, installing the profile when the person taps OK.
public struct VPNPermissionView: View {
    private enum Metrics {
        static let imageHeight: CGFloat = 120
        static let titleSpacing: CGFloat = 20
        static let messageSpacing: CGFloat = 10
        static let buttonSpacing: CGFloat = 40
        static let footerSpacing: CGFloat = 9

        /// Keeps the column readable on iPad, Mac Catalyst and the unfolded iPhone Duo.
        static let maxContentWidth: CGFloat = 480
    }

    @StateObject private var store: VPNPermissionStore

    public init(dependencies: VPNPermission.Dependencies) {
        self.init(initialState: VPNPermission.State(), dependencies: dependencies)
    }

    init(initialState: VPNPermission.State, dependencies: VPNPermission.Dependencies) {
        _store = StateObject(
            wrappedValue: VPNPermissionStore(
                initialState: initialState,
                dependencies: dependencies
            ))
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .padding(PIASpacing.s20)
                    .frame(maxWidth: Metrics.maxContentWidth)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(VPNPermissionAccessibility.screen)
        .piaDialog(deniedDialog)
        .onAppear {
            store.send(.onAppear)
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            Asset.imageVpnAllow.swiftUIImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Metrics.imageHeight)
                .accessibilityHidden(true)

            Text(L10n.VpnPermission.Body.title)
                .typography(.title2, color: .pia.onBackground)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, Metrics.titleSpacing)

            Text(L10n.VpnPermission.Body.subtitle(L10n.Global.ok))
                .typography(.body2, color: .pia.onBackground)
                .multilineTextAlignment(.center)
                .padding(.top, Metrics.messageSpacing)

            Button {
                store.send(.submitTapped)
            } label: {
                Text(L10n.Global.ok).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary, isLoading: store.state.phase == .requesting))
            .accessibilityIdentifier(VPNPermissionAccessibility.submit)
            .padding(.top, Metrics.buttonSpacing)

            Text(L10n.VpnPermission.Body.footer)
                .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, Metrics.footerSpacing)
        }
    }

    private var deniedDialog: PIADialog? {
        guard store.state.phase == .denied else { return nil }

        var message = L10n.VpnPermission.Disallow.Message.basic
        var actions: [PIADialog.Action] = []
        if store.state.canContactSupport {
            message += "\n" + L10n.VpnPermission.Disallow.Message.support
            actions.append(
                .init(
                    title: L10n.VpnPermission.Disallow.contact,
                    identifier: VPNPermissionAccessibility.contactSupportButton,
                    handler: { store.send(.contactSupportTapped) }
                ))
        }
        actions.append(
            .init(
                title: L10n.Global.ok,
                role: .cancel,
                identifier: VPNPermissionAccessibility.deniedOKButton,
                handler: { store.send(.deniedAcknowledged) }
            ))

        return PIADialog(title: L10n.VpnPermission.title, message: message, actions: actions)
    }
}

/// Stable identifiers for the UI tests.
///
/// `screen` and `submit` must match `AccessibilityId.VPNPermission` in the app, which the E2E
/// tests read.
public enum VPNPermissionAccessibility {
    public static let screen = "id.vpnPermission.screen"
    public static let submit = "id.vpnPermission.ok.button"
    public static let contactSupportButton = "id.vpnPermission.denied.contact.button"
    public static let deniedOKButton = "id.vpnPermission.denied.ok.button"
}

private extension VPNPermission.Dependencies {
    static func preview(result: Result<Void, any Error> = .success(())) -> Self {
        .init(requestPermission: { result }, canSendMail: { true }, emit: { _ in })
    }
}

#Preview("Idle") {
    VPNPermissionView(dependencies: .preview())
}

#Preview("Requesting") {
    VPNPermissionView(
        initialState: VPNPermission.State(phase: .requesting),
        dependencies: .preview()
    )
}

#Preview("Denied") {
    VPNPermissionView(
        initialState: VPNPermission.State(phase: .denied, canContactSupport: true),
        dependencies: .preview(result: .failure(CancellationError()))
    )
}
