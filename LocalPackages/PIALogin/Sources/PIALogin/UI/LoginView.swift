//
//  LoginView.swift
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
import PIALibrary
import PIALocalizations
import PIASwiftUI
import SwiftUI

/// Signs in with a username and password, an App Store receipt or a magic email link.
public struct LoginView: View {
    private enum Metrics {
        static let fieldHeight: CGFloat = 50
        static let fieldSpacing: CGFloat = 15
        /// Keeps the column readable on iPad, Mac Catalyst and the unfolded iPhone Duo.
        static let maxContentWidth: CGFloat = 480
    }

    @StateObject private var store: LoginStore
    @FocusState private var focusedField: Login.Field?

    public init(initialState: Login.State = Login.State(), dependencies: Login.Dependencies) {
        _store = StateObject(
            wrappedValue: LoginStore(initialState: initialState, dependencies: dependencies)
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
        .disabled(store.state.inFlight != nil)
        .task { store.send(.onAppear) }
        .alert(
            L10n.Account.Restore.Failure.title,
            isPresented: store.binding(\.isBadReceiptAlertPresented) { _ in .alertDismissed },
            actions: {
                Button(L10n.Global.close, role: .cancel) {}
            },
            message: {
                Text(L10n.Account.Restore.Failure.message)
            }
        )
        .modifier(
            MagicLinkPrompt(
                isPresented: store.binding(\.isMagicLinkPromptPresented) { _ in .magicLinkPromptDismissed },
                email: store.binding(\.magicLinkEmail) { .magicLinkEmailChanged($0) },
                send: { store.send(.magicLinkSendTapped) }
            )
        )
    }

    private var content: some View {
        VStack(spacing: 0) {
            Text(L10n.Welcome.Login.title)
                .typography(.subtitle1, color: .pia.onBackground)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: Metrics.fieldSpacing) {
                TextField(
                    L10n.Welcome.Login.Username.placeholder,
                    text: store.binding(\.username) { .usernameChanged($0) }
                )
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.next)
                .focused($focusedField, equals: .username)
                .onSubmit { focusedField = .password }
                .accessibilityIdentifier(LoginAccessibility.username)
                .modifier(fieldStyle(.username))

                SecureField(
                    L10n.Welcome.Login.Password.placeholder,
                    text: store.binding(\.password) { .passwordChanged($0) }
                )
                .textContentType(.password)
                .submitLabel(.go)
                .focused($focusedField, equals: .password)
                .onSubmit(logIn)
                .accessibilityIdentifier(LoginAccessibility.password)
                .modifier(fieldStyle(.password))
            }
            .padding(.top, PIASpacing.s32)

            Button(action: logIn) {
                Text(L10n.Welcome.Login.submit.uppercased()).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary, isLoading: store.state.inFlight != nil))
            .accessibilityIdentifier(LoginAccessibility.submit)
            .padding(.top, Metrics.fieldSpacing)

            VStack(spacing: 0) {
                linkButton(L10n.Welcome.Login.Receipt.button) { store.send(.receiptLoginTapped) }
                linkButton(L10n.Welcome.Login.Restore.button) { store.send(.restorePurchaseTapped) }
                linkButton(L10n.Welcome.Login.Magic.Link.title) { store.send(.magicLinkTapped) }
            }
            .padding(.top, PIASpacing.s12)
        }
    }

    private func logIn() {
        focusedField = nil
        store.send(.loginTapped)
    }

    private func fieldStyle(_ field: Login.Field) -> some ViewModifier {
        LoginFieldStyle(
            isFocused: focusedField == field,
            isInvalid: store.state.invalidFields.contains(field),
            height: Metrics.fieldHeight
        )
    }

    private func linkButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .typography(.button2)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(PIAButtonStyle(.plain))
    }
}

extension Login.State {
    fileprivate var isBadReceiptAlertPresented: Bool { alert == .badReceipt }
}

private struct LoginFieldStyle: ViewModifier {
    let isFocused: Bool
    let isInvalid: Bool
    let height: CGFloat

    func body(content: Content) -> some View {
        content
            .typography(.body2, color: .pia.onSurface)
            .padding(.horizontal, PIASpacing.s16)
            .frame(height: height)
            .modifier(
                TextFieldModifier(
                    isFocused: isFocused || isInvalid,
                    outline: .pia.outline,
                    focusedOutline: isInvalid ? .pia.error : .pia.primary
                )
            )
    }
}

/// Asks for the email to send the sign-in link to.
///
/// Alerts only take text fields from iOS 16, so iOS 15 gets a small sheet instead.
private struct MagicLinkPrompt: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var email: String
    let send: () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.alert(L10n.Welcome.Login.Magic.Link.title, isPresented: $isPresented) {
                TextField(L10n.Welcome.Purchase.Email.placeholder, text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                Button(L10n.Signup.Purchase.Uncredited.Alert.Button.cancel, role: .cancel) {}
                Button(L10n.Welcome.Login.Magic.Link.send, action: send)
            }
        } else {
            content.sheet(isPresented: $isPresented) {
                MagicLinkSheet(email: $email, cancel: { isPresented = false }, send: send)
            }
        }
    }
}

private struct MagicLinkSheet: View {
    @Binding var email: String
    let cancel: () -> Void
    let send: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: PIASpacing.s16) {
            Text(L10n.Welcome.Login.Magic.Link.title)
                .typography(.subtitle1, color: .pia.onBackground)
                .multilineTextAlignment(.center)

            TextField(L10n.Welcome.Purchase.Email.placeholder, text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.send)
                .focused($isFocused)
                .onSubmit(send)
                .modifier(LoginFieldStyle(isFocused: isFocused, isInvalid: false, height: 50))

            Button(action: send) {
                Text(L10n.Welcome.Login.Magic.Link.send).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary))

            Button(action: cancel) {
                Text(L10n.Signup.Purchase.Uncredited.Alert.Button.cancel).typography(.button2)
            }
            .buttonStyle(PIAButtonStyle(.plain))

            Spacer()
        }
        .padding(PIASpacing.s24)
        .background(Color.pia.background.ignoresSafeArea())
        .onAppear { isFocused = true }
    }
}

/// Stable identifiers for the UI tests.
///
/// Must match `Accessibility.Id.Login` in the app, which the E2E tests read. `password` shares the
/// submit button's identifier for historical reasons; the tests tell them apart by element type.
public enum LoginAccessibility {
    public static let submit = "id.login.submit"
    public static let username = "id.login.username"
    public static let password = "id.login.submit"
    public static let errorBanner = "id.login.error.banner"
}

private extension Login.Dependencies {
    static var preview: Self {
        .init(
            login: { _ in .failure(.unauthorized) },
            loginWithReceipt: { .failure(.badReceipt) },
            loginWithMagicLinkToken: { _ in .failure(.unauthorized) },
            requestMagicLink: { _ in .success(Login.Success()) },
            magicLinkTokens: { AsyncStream { $0.finish() } },
            emit: { _ in }
        )
    }
}

#Preview("Empty") {
    LoginView(dependencies: .preview)
}

#Preview("Invalid") {
    LoginView(initialState: .init(invalidFields: [.username, .password]), dependencies: .preview)
}

#Preview("Logging in") {
    LoginView(initialState: .init(username: "p1234567", password: "secret", inFlight: .credentials), dependencies: .preview)
}
