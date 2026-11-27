//
//  SideMenuView.swift
//  PIASideMenu
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
import PIALibrary
import PIALocalizations
import PIASwiftUI
import SwiftUI

public struct SideMenuView: View {
    private enum Metrics {
        static let avatarSize: CGFloat = 46
        static let iconSize: CGFloat = 20
        static let spinnerSize: CGFloat = 50
    }

    @StateObject private var store: SideMenuStore
    private let version: String

    public init(version: String, dependencies: SideMenu.Dependencies) {
        self.init(
            version: version,
            initialState: SideMenu.State(account: dependencies.currentAccount()),
            dependencies: dependencies
        )
    }

    init(version: String, initialState: SideMenu.State, dependencies: SideMenu.Dependencies) {
        self.version = version
        _store = StateObject(wrappedValue: SideMenuStore(initialState: initialState, dependencies: dependencies))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                if let expiration = account.expiration {
                    expirationBanner(expiration)
                }
                Divider()
                ForEach(SideMenu.Item.primary, id: \.self, content: row)
                Divider()
                ForEach(SideMenu.Item.secondary, id: \.self, content: row)
                Text(version)
                    .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                    .padding(PIASpacing.s16)
            }
        }
        .background(Color.pia.surfaceContainerPrimary.ignoresSafeArea())
        .disabled(store.state.isLoading)
        .overlay {
            if store.state.isLoading {
                LoadingView(image: Asset.piaSpinner.swiftUIImage)
                    .frame(width: Metrics.spinnerSize, height: Metrics.spinnerSize)
            }
        }
        .alert(
            store.state.alert?.title ?? "",
            isPresented: isAlertPresented,
            presenting: store.state.alert,
            actions: alertActions,
            message: { Text($0.message) }
        )
        .onAppear { store.send(.onAppear) }
    }

    private var account: SideMenu.Account { store.state.account }

    // MARK: Header

    private var header: some View {
        HStack(spacing: PIASpacing.s16) {
            Asset.imageRobot.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: Metrics.avatarSize, height: Metrics.avatarSize)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: PIASpacing.s8) {
                Text(account.username)
                    .typography(.subtitle1, color: .pia.onSurface)
                    .accessibilityLabel(L10n.Menu.Accessibility.loggedAs(account.username))

                if let plan = account.managedPlan {
                    Button {
                        store.send(.manageSubscriptionTapped)
                    } label: {
                        subscriptionText(plan)
                            .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                            .multilineTextAlignment(.leading)
                    }
                    .accessibilityIdentifier(SideMenuAccessibility.manageSubscription)
                }
            }
        }
        .padding(PIASpacing.s16)
    }

    private func subscriptionText(_ plan: Plan) -> Text {
        let planName =
            switch plan {
            case .yearly: L10n.Account.Subscriptions.yearly
            case .monthly: L10n.Account.Subscriptions.monthly
            default: L10n.Account.Subscriptions.trial
            }
        let message = AttributedString(
            L10n.Account.Subscriptions.Short.message,
            highlighting: L10n.Account.Subscriptions.Short.linkMessage
        ) { $0.foregroundColor = .pia.primary }
        return Text(planName + "\n") + Text(message)
    }

    // MARK: Expiration

    private func expirationBanner(_ expiration: SideMenu.Expiration) -> some View {
        Button {
            store.send(.expirationTapped)
        } label: {
            HStack(spacing: PIASpacing.s8) {
                VStack(alignment: .leading, spacing: PIASpacing.s4) {
                    Text("\(L10n.Menu.Expiration.expiresIn) \(expiration.timeLeft)".uppercased())
                        .typography(.caption1)
                    Text(L10n.Menu.Expiration.upgrade.capitalized)
                        .typography(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Asset.accessoryExpire.swiftUIImage
                    .renderingMode(.template)
                    .accessibilityHidden(true)
            }
            .foregroundColor(.pia.onError)
            .padding(.horizontal, PIASpacing.s24)
            .padding(.vertical, PIASpacing.s12)
            .background(Color.pia.error)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(SideMenuAccessibility.expiration)
    }

    // MARK: Items

    private func row(_ item: SideMenu.Item) -> some View {
        Button {
            store.send(.itemTapped(item))
        } label: {
            HStack(spacing: PIASpacing.s12) {
                item.icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                    .accessibilityHidden(true)
                Text(item.title)
                    .typography(.body2, color: .pia.onSurface)
            }
            .padding(.horizontal, PIASpacing.s16)
            .padding(.vertical, PIASpacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .piaRowButtonStyle()
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }

    // MARK: Alerts

    private var isAlertPresented: Binding<Bool> {
        Binding(
            get: { store.state.alert != nil },
            set: { if !$0 { store.send(.alertDismissed) } }
        )
    }

    @ViewBuilder
    private func alertActions(_ alert: SideMenu.Alert) -> some View {
        switch alert {
        case .logoutConfirmation:
            Button(L10n.Global.cancel, role: .cancel) {}
            Button(L10n.Menu.Logout.confirm, role: .destructive) { store.send(.logoutConfirmed) }
                .accessibilityIdentifier(SideMenuAccessibility.logoutConfirm)
        case .renewingTrial:
            Button(L10n.Global.cancel, role: .cancel) {}
            Button(L10n.Menu.Renewal.purchase) { store.send(.upgradeTrialConfirmed) }
                .keyboardShortcut(.defaultAction)
        case .renewingNonRenewable:
            Button(L10n.Global.cancel, role: .cancel) {}
            Button(L10n.Menu.Renewal.renew) { store.send(.renewOnWebsiteConfirmed) }
                .keyboardShortcut(.defaultAction)
        case .renewalSucceeded, .failure:
            Button(L10n.Global.close, role: .cancel) {}
        }
    }
}

public enum SideMenuAccessibility {
    public static let manageSubscription = "id.menu.manageSubscription"
    public static let expiration = "id.menu.expiration"
    public static let logout = "id.menu.logout"
    /// Shared with every UIKit destructive dialog, which the UI tests already look for.
    public static let logoutConfirm = "id.dialog.destructive.button"
}

// MARK: Display

extension SideMenu.Item {
    fileprivate var title: String {
        switch self {
        case .destination(.regionSelection): L10n.Menu.Item.region
        case .destination(.account): L10n.Menu.Item.account
        case .destination(.dedicatedIP): L10n.Dedicated.Ip.title
        case .destination(.settings): L10n.Menu.Item.settings
        case .destination(.about): L10n.Menu.Item.about
        case .website(.privacy): L10n.Menu.Item.Web.privacy
        case .website(.home): L10n.Menu.Item.Web.home
        case .website(.support): L10n.Menu.Item.Web.support
        case .logout: L10n.Menu.Item.logout
        }
    }

    fileprivate var icon: Image {
        let asset: ImageAsset =
            switch self {
            case .destination(.regionSelection): Asset.iconRegion
            case .destination(.account): Asset.iconAccount
            case .destination(.dedicatedIP): Asset.iconDip
            case .destination(.settings): Asset.iconSettings
            case .destination(.about): Asset.iconmenuAbout
            case .website(.privacy): Asset.iconmenuPrivacy
            case .website(.home): Asset.iconHomepage
            case .website(.support): Asset.iconContact
            case .logout: Asset.iconLogout
            }
        return asset.swiftUIImage
    }

    fileprivate var accessibilityIdentifier: String {
        switch self {
        case .destination(let destination): "id.menu.\(destination)"
        case .website(let website): "id.menu.web.\(website)"
        case .logout: SideMenuAccessibility.logout
        }
    }
}

extension SideMenu.Expiration {
    fileprivate var timeLeft: String {
        switch self {
        case .days(let days): L10n.Menu.Expiration.days(days)
        case .hours(let hours): L10n.Menu.Expiration.hours(hours)
        case .underAnHour: L10n.Menu.Expiration.oneHour
        }
    }
}

extension SideMenu.Alert {
    fileprivate var title: String {
        switch self {
        case .logoutConfirmation: L10n.Menu.Logout.title
        case .renewingTrial, .renewingNonRenewable: L10n.Menu.Renewal.title
        case .renewalSucceeded: L10n.Renewal.Success.title
        case .failure: L10n.Global.error
        }
    }

    fileprivate var message: String {
        switch self {
        case .logoutConfirmation: L10n.Menu.Logout.message
        case .renewingTrial: L10n.Menu.Renewal.Message.trial
        case .renewingNonRenewable: L10n.Menu.Renewal.Message.website
        case .renewalSucceeded: L10n.Renewal.Success.message
        case .failure(let message): message
        }
    }
}

// MARK: Previews

private extension SideMenu.Dependencies {
    static func preview(_ account: SideMenu.Account) -> Self {
        .init(
            currentAccount: { account },
            accountUpdates: { AsyncStream { $0.finish() } },
            renew: { .renewed },
            logout: {},
            emit: { _ in }
        )
    }
}

#Preview("Managed subscription") {
    SideMenuView(version: "Version 4.0 (1234)", dependencies: .preview(.init(username: "p1234567", managedPlan: .yearly)))
}

#Preview("Expiring") {
    SideMenuView(
        version: "Version 4.0 (1234)",
        dependencies: .preview(.init(username: "p1234567", expiration: .days(3)))
    )
}

#Preview("Loading") {
    let account = SideMenu.Account(username: "p1234567")
    return SideMenuView(
        version: "Version 4.0 (1234)",
        initialState: .init(account: account, isLoading: true),
        dependencies: .preview(account)
    )
}
