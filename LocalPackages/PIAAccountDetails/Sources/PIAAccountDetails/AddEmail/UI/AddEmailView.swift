//
//  AddEmailView.swift
//  PIAAccountDetails
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

import AuthenticationServices
import PIAAssetsMobile
import PIADesignSystem
import PIALibrary
import PIALocalizations
import PIASwiftUI
import SwiftUI

/// Asks a logged-in account with no email to set one, by typing it or through Sign in with Apple,
/// then shows the credentials sent to it.
public struct AddEmailView: View {
    private enum Metrics {
        static let appleButtonHeight: CGFloat = 50

        /// Keeps the column readable on iPad, Mac Catalyst and the unfolded iPhone Duo.
        static let maxContentWidth: CGFloat = 480
    }

    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var store: AddEmailStore

    public init(email: String?, dependencies: AddEmail.Dependencies) {
        // Not delegated to the internal init: previews can't compile `self.init` here.
        _store = StateObject(
            wrappedValue: AddEmailStore(
                initialState: AddEmail.State(email: email ?? ""),
                dependencies: dependencies
            ))
    }

    init(initialState: AddEmail.State, dependencies: AddEmail.Dependencies) {
        _store = StateObject(
            wrappedValue: AddEmailStore(
                initialState: initialState,
                dependencies: dependencies
            ))
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Group {
                    switch store.state.step {
                    case .form:
                        form
                    case .done(let email, let credentials):
                        done(email: email, credentials: credentials)
                    }
                }
                .padding(PIASpacing.s20)
                .frame(maxWidth: Metrics.maxContentWidth)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.pia.background.ignoresSafeArea())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AddEmailAccessibility.screen)
        .alert(item: alertBinding, content: makeAlert)
    }

    // MARK: Form

    private var isBusy: Bool {
        store.state.isSubmitting || store.state.isLoggingOut
    }

    private var form: some View {
        VStack(spacing: PIASpacing.s16) {
            VStack(spacing: PIASpacing.s8) {
                Text(L10n.Set.Email.Form.email)
                    .typography(.title2, color: .pia.onBackground)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(L10n.Set.Email.why)
                    .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                    .multilineTextAlignment(.center)
            }

            PIATextField(
                placeholder: L10n.Account.Email.placeholder,
                text: store.binding(\.email) { .emailChanged($0) },
                errorMessage: store.state.emailError.map(\.message)
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .onSubmit { store.send(.submitTapped) }
            .disabled(isBusy)
            .accessibilityIdentifier(AddEmailAccessibility.email)

            Button {
                store.send(.submitTapped)
            } label: {
                Text(L10n.Global.update).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary, isLoading: store.state.isSubmitting))
            .disabled(store.state.isLoggingOut)
            .accessibilityIdentifier(AddEmailAccessibility.submit)

            Text(L10n.Global.or)
                .textCase(.uppercase)
                .typography(.caption1, color: .pia.onSurfaceContainerSecondary)

            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.email]
            } onCompletion: { result in
                // A failure is the person cancelling the sheet, which leaves the form as it was.
                guard case .success(let authorization) = result,
                    let credential = authorization.credential as? ASAuthorizationAppleIDCredential
                else { return }
                store.send(.appleIDAuthorized(email: credential.resolvedEmail))
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .whiteOutline : .black)
            // The button keeps the style it was created with, so a theme change recreates it.
            .id(colorScheme)
            .frame(height: Metrics.appleButtonHeight)
            .disabled(isBusy)
            .accessibilityIdentifier(AddEmailAccessibility.signInWithApple)

            Button {
                store.send(.logoutTapped)
            } label: {
                Text(L10n.Menu.Logout.title).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.plain, isLoading: store.state.isLoggingOut))
            .disabled(store.state.isSubmitting)
            .accessibilityIdentifier(AddEmailAccessibility.logout)
            .padding(.top, PIASpacing.s8)
        }
    }

    // MARK: Done

    private func done(email: String, credentials: AddEmail.Credentials) -> some View {
        VStack(spacing: PIASpacing.s24) {
            Asset.imagePurchaseSuccess.swiftUIImage
                .accessibilityHidden(true)

            Text(L10n.Set.Email.Success.messageFormat(email))
                .typography(.body1, color: .pia.onBackground)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(AddEmailAccessibility.successMessage)

            VStack(alignment: .leading, spacing: PIASpacing.s16) {
                credential(
                    caption: L10n.Account.Username.caption,
                    value: credentials.username,
                    identifier: AddEmailAccessibility.username
                )
                credential(
                    caption: L10n.Set.Email.Password.caption,
                    value: credentials.password,
                    identifier: AddEmailAccessibility.password
                )
            }
            .piaCard()

            Button {
                store.send(.closeTapped)
            } label: {
                Text(L10n.Global.close).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary))
            .accessibilityIdentifier(AddEmailAccessibility.close)
        }
    }

    private func credential(caption: String, value: String, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: PIASpacing.s4) {
            Text(caption)
                .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
            Text(value)
                .typography(.subtitle1, color: .pia.onSurface)
                .textSelection(.enabled)
                .accessibilityIdentifier(identifier)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Alerts

    private var alertBinding: Binding<AddEmail.Alert?> {
        Binding(
            get: { store.state.alert },
            set: { if $0 == nil { store.send(.alertDismissed) } }
        )
    }

    private func makeAlert(_ alert: AddEmail.Alert) -> Alert {
        switch alert {
        case .consent:
            return Alert(
                title: Text(L10n.Gdpr.Collect.Data.title),
                message: Text(L10n.Gdpr.Collect.Data.description),
                primaryButton: .default(Text(L10n.Gdpr.Accept.Button.title)) { store.send(.consentGiven) },
                secondaryButton: .cancel(Text(L10n.Global.cancel)) { store.send(.alertDismissed) }
            )
        case .updateFailed:
            return Alert(
                title: Text(L10n.Global.error),
                message: Text(L10n.Account.Set.Email.error),
                dismissButton: .cancel(Text(L10n.Global.close)) { store.send(.alertDismissed) }
            )
        }
    }
}

/// Stable identifiers for the UI tests.
public enum AddEmailAccessibility {
    public static let screen = "id.addEmail.screen"
    public static let email = "id.addEmail.email.field"
    public static let submit = "id.addEmail.submit.button"
    public static let signInWithApple = "id.addEmail.signInWithApple.button"
    public static let logout = "id.addEmail.logout.button"
    public static let successMessage = "id.addEmail.success.message"
    public static let username = "id.addEmail.username"
    public static let password = "id.addEmail.password"
    public static let close = "id.addEmail.close.button"
}

private extension Validator.EmailValidationError {
    var message: String {
        switch self {
        case .emailIsEmpty: L10n.Email.Validation.empty
        case .emailIsInvalid: L10n.Email.Validation.invalid
        }
    }
}

private extension AddEmail.Dependencies {
    static var preview: Self {
        .init(
            updateEmail: { _ in AddEmail.Credentials(username: "p1234567", password: "x7Kq2mPz") },
            storedAppleIDEmail: { nil },
            storeAppleIDEmail: { _ in },
            clearTemporaryPassword: {},
            logout: { true },
            emit: { _ in }
        )
    }
}

#Preview("Form") {
    AddEmailView(email: nil, dependencies: .preview)
}

#Preview("Invalid email") {
    AddEmailView(
        initialState: AddEmail.State(email: "foo@", emailError: .emailIsInvalid),
        dependencies: .preview
    )
}

#Preview("Submitting") {
    AddEmailView(
        initialState: AddEmail.State(email: "user@example.com", hasConsented: true, isSubmitting: true),
        dependencies: .preview
    )
}

#Preview("Done") {
    AddEmailView(
        initialState: AddEmail.State(
            step: .done(
                email: "user@example.com",
                credentials: AddEmail.Credentials(username: "p1234567", password: "x7Kq2mPz")
            )
        ),
        dependencies: .preview
    )
}
