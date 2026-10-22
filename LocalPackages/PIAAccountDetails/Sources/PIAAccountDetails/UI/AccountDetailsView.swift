//
//  AccountDetailsView.swift
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

import PIAAssetsMobile
import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

/// Shows the logged-in account: username, plan expiry, subscription management, restoring an
/// uncredited purchase and deleting the account.
public struct AccountDetailsView: View, ViewWithTitle {
    private enum Metrics {
        static let trashIconSize: CGFloat = 20

        /// Keeps the column readable on iPad, Mac Catalyst and the unfolded iPhone Duo.
        static let maxContentWidth: CGFloat = 480
    }

    @StateObject private var store: AccountDetailsStore

    public var navigationTitle: String { L10n.Menu.Item.account }

    public init(dependencies: AccountDetails.Dependencies) {
        self.init(
            initialState: AccountDetails.State(account: dependencies.currentAccount()),
            dependencies: dependencies
        )
    }

    init(initialState: AccountDetails.State, dependencies: AccountDetails.Dependencies) {
        _store = StateObject(
            wrappedValue: AccountDetailsStore(
                initialState: initialState,
                dependencies: dependencies
            ))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: PIASpacing.s16) {
                if let account = store.state.account {
                    accountCard(account)

                    if account.isRenewable {
                        restoreCard
                    }
                }

                deleteAccountButton
                    .padding(.top, PIASpacing.s8)
            }
            .padding(PIASpacing.s16)
            .frame(maxWidth: Metrics.maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .background(Color.pia.background.ignoresSafeArea())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccountDetailsAccessibility.screen)
        .alert(item: alertBinding, content: makeAlert)
        .onAppear {
            store.send(.onAppear)
        }
    }

    // MARK: Account

    private func accountCard(_ account: AccountDetails.Account) -> some View {
        VStack(alignment: .leading, spacing: PIASpacing.s16) {
            VStack(alignment: .leading, spacing: PIASpacing.s4) {
                Text(L10n.Account.Username.caption)
                    .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                Text(account.username)
                    .typography(.subtitle1, color: .pia.onSurface)
                    .textSelection(.enabled)
                    .accessibilityIdentifier(AccountDetailsAccessibility.username)
            }

            expiryText(account.expiry)
                .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                .accessibilityIdentifier(AccountDetailsAccessibility.expiry)

            if account.canManageSubscription {
                Button {
                    store.send(.manageSubscriptionTapped)
                } label: {
                    Text(manageSubscriptionMessage)
                        .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                        .multilineTextAlignment(.leading)
                }
                .accessibilityIdentifier(AccountDetailsAccessibility.manageSubscription)
            }
        }
        .accountCard()
    }

    private func expiryText(_ expiry: AccountDetails.Account.Expiry) -> Text {
        switch expiry {
        case .expired:
            return Text(L10n.Account.ExpiryDate.expired)
        case .expires(let date):
            var message = AttributedString(L10n.Account.ExpiryDate.information(date))
            if let range = message.range(of: date) {
                message[range].foregroundColor = .pia.primary
                message[range].inlinePresentationIntent = .stronglyEmphasized
            }
            return Text(message)
        }
    }

    /// "You can manage your subscription from here." with "here." styled as the link.
    private var manageSubscriptionMessage: AttributedString {
        var message = AttributedString(L10n.Account.Subscriptions.message)
        if let range = message.range(of: L10n.Account.Subscriptions.linkMessage) {
            message[range].foregroundColor = .pia.primary
        }
        return message
    }

    // MARK: Restore

    private var restoreCard: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s12) {
            Text(L10n.Account.Restore.title)
                .typography(.subtitle2, color: .pia.onSurface)
                .accessibilityAddTraits(.isHeader)

            Text(L10n.Account.Restore.description)
                .typography(.body2, color: .pia.onSurfaceContainerSecondary)

            Button {
                store.send(.restoreTapped)
            } label: {
                Text(L10n.Account.Restore.button).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.secondary, isLoading: store.state.isRestoring))
            .accessibilityIdentifier(AccountDetailsAccessibility.restore)
        }
        .accountCard()
    }

    // MARK: Delete

    private var deleteAccountButton: some View {
        Button {
            store.send(.deleteAccountTapped)
        } label: {
            HStack(spacing: PIASpacing.s8) {
                Asset.iconTrash.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Metrics.trashIconSize, height: Metrics.trashIconSize)
                    .accessibilityHidden(true)
                Text(L10n.Account.delete)
                    .underline()
                    .typography(.body2)
            }
            .foregroundColor(.pia.error)
        }
        .accessibilityIdentifier(AccountDetailsAccessibility.deleteAccount)
    }

    // MARK: Alerts

    private var alertBinding: Binding<AccountDetails.Alert?> {
        Binding(
            get: { store.state.alert },
            set: { if $0 == nil { store.send(.alertDismissed) } }
        )
    }

    private func makeAlert(_ alert: AccountDetails.Alert) -> Alert {
        let close = Alert.Button.cancel(Text(L10n.Global.close)) { store.send(.alertDismissed) }
        switch alert {
        case .restoreSucceeded:
            return Alert(
                title: Text(L10n.Renewal.Success.title),
                message: Text(L10n.Renewal.Success.message),
                dismissButton: close
            )
        case .noRedeemablePurchase:
            return Alert(
                title: Text(L10n.Account.Restore.Failure.title),
                message: Text(L10n.Account.Restore.Failure.message),
                dismissButton: close
            )
        case .failure(let message):
            return Alert(title: Text(L10n.Global.error), message: Text(message), dismissButton: close)
        }
    }
}

/// Stable identifiers for the UI tests.
public enum AccountDetailsAccessibility {
    public static let screen = "id.accountDetails.screen"
    public static let username = "id.accountDetails.username"
    public static let expiry = "id.accountDetails.expiry"
    public static let manageSubscription = "id.accountDetails.manageSubscription.button"
    public static let restore = "id.accountDetails.restore.button"
    public static let deleteAccount = "id.accountDetails.delete.button"
}

extension View {
    fileprivate func accountCard() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(PIASpacing.s16)
            .background(Color.pia.surfaceContainerPrimary)
            .clipShape(RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous))
    }
}

private extension AccountDetails.Account {
    static func preview(
        expiry: Expiry = .expires(on: "October 19, 2027"),
        canManageSubscription: Bool = true,
        isRenewable: Bool = false
    ) -> Self {
        .init(
            username: "p1234567",
            expiry: expiry,
            canManageSubscription: canManageSubscription,
            isRenewable: isRenewable
        )
    }
}

private extension AccountDetails.Dependencies {
    static func preview(_ account: AccountDetails.Account) -> Self {
        .init(
            currentAccount: { account },
            refreshAccount: {},
            accountUpdates: { AsyncStream { $0.finish() } },
            restorePurchase: { .renewed },
            emit: { _ in }
        )
    }
}

#Preview("Active") {
    AccountDetailsView(dependencies: .preview(.preview()))
}

#Preview("Expired") {
    AccountDetailsView(dependencies: .preview(.preview(expiry: .expired, canManageSubscription: false)))
}

#Preview("Renewable, restoring") {
    let account = AccountDetails.Account.preview(isRenewable: true)
    return AccountDetailsView(
        initialState: AccountDetails.State(account: account, isRestoring: true),
        dependencies: .preview(account)
    )
}

#Preview("Mac") {
    AccountDetailsView(dependencies: .preview(.preview(canManageSubscription: false, isRenewable: true)))
}
