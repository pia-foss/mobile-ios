//
//  RestoreSignupView.swift
//  PIALogin
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

/// Asks for the email of a purchase whose account was never created, then restores it.
public struct RestoreSignupView: View {
    private enum Metrics {
        /// Keeps the column readable on iPad, Mac Catalyst and the unfolded iPhone Duo.
        static let maxContentWidth: CGFloat = 480
    }

    @StateObject private var store: RestoreSignupStore
    @FocusState private var isEmailFocused: Bool

    public init(
        initialState: RestoreSignup.State = RestoreSignup.State(),
        dependencies: RestoreSignup.Dependencies
    ) {
        _store = StateObject(
            wrappedValue: RestoreSignupStore(initialState: initialState, dependencies: dependencies)
        )
    }

    public var body: some View {
        ScrollView {
            content
                .padding(PIASpacing.s24)
                .frame(maxWidth: Metrics.maxContentWidth)
                .frame(maxWidth: .infinity)
        }
        .background(Color.pia.background.ignoresSafeArea())
        .disabled(store.state.isRestoring)
        .onChange(of: store.state.isEmailInvalid) { isInvalid in
            if isInvalid { isEmailFocused = true }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            Text(L10n.Welcome.Restore.title)
                .typography(.subtitle1, color: .pia.onBackground)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(L10n.Welcome.Restore.subtitle)
                .typography(.body2, color: .pia.onSurfaceContainerPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, PIASpacing.s16)

            TextField(
                L10n.Welcome.Restore.Email.placeholder,
                text: store.binding(\.email) { .emailChanged($0) }
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .submitLabel(.send)
            .focused($isEmailFocused)
            .onSubmit(submit)
            .accessibilityIdentifier(RestoreSignupAccessibility.email)
            .modifier(FormFieldStyle(isFocused: isEmailFocused, isInvalid: store.state.isEmailInvalid))
            .padding(.top, PIASpacing.s32)

            Button(action: submit) {
                Text(L10n.Welcome.Restore.submit.uppercased()).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary, isLoading: store.state.isRestoring))
            .accessibilityIdentifier(RestoreSignupAccessibility.submit)
            .padding(.top, PIASpacing.s16)
        }
    }

    private func submit() {
        isEmailFocused = false
        store.send(.submitTapped)
    }
}

/// Stable identifiers for the UI tests.
public enum RestoreSignupAccessibility {
    public static let email = "id.restoreSignup.email"
    public static let submit = "id.restoreSignup.submit"
}

private extension RestoreSignup.Dependencies {
    static var preview: Self {
        .init(restorePurchases: { .failure(.nothingToRestore) }, emit: { _ in })
    }
}

#Preview("Empty") {
    RestoreSignupView(dependencies: .preview)
}

#Preview("Invalid") {
    RestoreSignupView(initialState: .init(email: "nope", isEmailInvalid: true), dependencies: .preview)
}

#Preview("Restoring") {
    RestoreSignupView(initialState: .init(email: "someone@example.com", isRestoring: true), dependencies: .preview)
}
