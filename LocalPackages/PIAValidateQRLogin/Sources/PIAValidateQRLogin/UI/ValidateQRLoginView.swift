//
//  ValidateQRLoginView.swift
//  PIAValidateQRLogin
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

public struct ValidateQRLoginView: View {
    @StateObject private var store: ValidateQRLoginStore

    public init(dependencies: ValidateQRLogin.Dependencies) {
        self.init(
            initialState: ValidateQRLogin.State(),
            dependencies: dependencies
        )
    }

    init(initialState: ValidateQRLogin.State, dependencies: ValidateQRLogin.Dependencies) {
        _store = StateObject(
            wrappedValue: ValidateQRLoginStore(
                initialState: initialState,
                dependencies: dependencies
            ))
    }

    public var body: some View {
        ZStack {
            Color.pia.background.ignoresSafeArea()

            Asset.navLogo.swiftUIImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 162, height: 82)
                .accessibilityHidden(true)
                .overlay(alignment: .bottom) {
                    ProgressView()
                        .controlSize(.large)
                        .alignmentGuide(.bottom) { $0[.top] - 7 }
                }
                .offset(y: -70)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert(L10n.Validateqr.Confirmation.title, isPresented: isPresented(.confirming)) {
            Button(L10n.Global.cancel, role: .cancel) { store.send(.cancelTapped) }
            Button(L10n.Validateqr.Confirmation.continue) { store.send(.confirmTapped) }
        } message: {
            Text(L10n.Validateqr.Confirmation.message)
        }
        .alert(L10n.ErrorAlert.ConnectionError.NoNetwork.title, isPresented: isPresented(.failed)) {
            Button(L10n.Global.ok) { store.send(.errorAcknowledged) }
        } message: {
            Text(L10n.ErrorAlert.ConnectionError.NoNetwork.message)
        }
    }

    private func isPresented(_ phase: ValidateQRLogin.Phase) -> Binding<Bool> {
        Binding(
            get: { store.state.phase == phase },
            set: { _ in }
        )
    }
}

#Preview("Confirming") {
    ValidateQRLoginView(
        dependencies: ValidateQRLogin.Dependencies(
            validate: { .success(()) },
            discardQRToken: {},
            emit: { _ in }
        )
    )
}

#Preview("Failed") {
    ValidateQRLoginView(
        initialState: ValidateQRLogin.State(phase: .failed),
        dependencies: ValidateQRLogin.Dependencies(
            validate: { .failure(CancellationError()) },
            discardQRToken: {},
            emit: { _ in }
        )
    )
}
