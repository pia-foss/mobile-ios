//
//  TrustedNetworksSettingsView.swift
//  PIASettings
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

public struct TrustedNetworksSettingsView: View, ViewWithTitle {
    /// Grows with Dynamic Type, so larger text gets fewer, wider cards instead of words broken mid-way
    @ScaledMetric(relativeTo: .title2) private var minimumCardWidth: CGFloat = 150
    @ObservedObject private var store: TrustedNetworksSettingsStore

    public var navigationTitle: String { L10n.Network.Management.Tool.title }

    public init(store: TrustedNetworksSettingsStore) {
        self.store = store
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    NMTDescription(text: L10n.Settings.Hotspothelper.description)

                    rulesGrid(width: proxy.size.width)
                        .padding(.horizontal, PIASpacing.s20)

                    if store.state.canAddNetworks {
                        addRuleButton
                            .padding(.top, PIASpacing.s24)
                    }
                }
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
        .task { store.send(.onAppear) }
        .alert(
            L10n.Settings.ApplicationSettings.KillSwitch.title,
            isPresented: store.binding(\.isKillSwitchWarningPresented) { _ in .killSwitchWarningDismissed },
            actions: {
                Button(L10n.Global.enable) {
                    store.send(.killSwitchWarningConfirmed)
                }
                .keyboardShortcut(.defaultAction)
                Button(L10n.Global.close, role: .cancel) {}
            },
            message: {
                Text(L10n.Settings.Nmt.Killswitch.disabled)
            }
        )
    }

    private func rulesGrid(width: CGFloat) -> some View {
        let metrics = GridMetrics(width: width, minimumCardWidth: minimumCardWidth)
        let columns = Array(
            repeating: GridItem(.fixed(metrics.cardWidth), spacing: GridMetrics.columnSpacing),
            count: metrics.columnCount
        )

        return LazyVGrid(columns: columns, alignment: .leading, spacing: GridMetrics.rowSpacing) {
            ForEach(store.state.rules) { rule in
                NetworkRuleCard(
                    rule: rule,
                    width: metrics.cardWidth,
                    isSquare: metrics.isSquare,
                    onSelect: { store.send(.behaviorSelected(rule.network, $0)) },
                    onRemove: rule.network.ssid.map { ssid in { store.send(.removeTapped(ssid: ssid)) } }
                )
            }
        }
    }

    private var addRuleButton: some View {
        Button {
            store.send(.addRuleTapped)
        } label: {
            HStack(spacing: PIASpacing.s8) {
                NMTAsset.iconAddRule.swiftUIImage
                    .renderingMode(.template)
                Text(L10n.Network.Management.Tool.Add.rule)
                    .typography(.button1, color: .pia.primary)
            }
            .foregroundColor(.pia.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .accessibilityLabel(L10n.Network.Management.Tool.Add.rule)
    }
}

/// Fits as many columns of at least `minimumCardWidth` as the width allows, wherever the screen is shown
/// (iPhone, a Settings sheet on iPad, either iPhone Duo display, Split View). Cards stay square while
/// there are several columns; in a single column they size to their content.
private struct GridMetrics {
    static let columnSpacing = PIASpacing.s16
    static let rowSpacing = PIASpacing.s20

    let columnCount: Int
    let cardWidth: CGFloat

    var isSquare: Bool { columnCount > 1 }

    init(width: CGFloat, minimumCardWidth: CGFloat) {
        let available = max(0, width - 2 * PIASpacing.s20)
        let columnCount = max(1, Int((available + Self.columnSpacing) / (minimumCardWidth + Self.columnSpacing)))

        self.columnCount = columnCount
        self.cardWidth = (available - Self.columnSpacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)
    }
}

#if DEBUG
    extension TrustedNetworksSettingsStore {
        static var preview: TrustedNetworksSettingsStore {
            let rules: [TrustedNetworksSettings.Rule] = [
                .init(network: .secureWiFi, behavior: .alwaysConnect),
                .init(network: .openWiFi, behavior: .alwaysDisconnect),
                .init(network: .mobileData, behavior: .retainState),
                .init(network: .custom(ssid: "Home"), behavior: .alwaysDisconnect)
            ]
            var state = TrustedNetworksSettings.State(rules: rules, canAddNetworks: true, isKillSwitchWarningPresented: false)
            state.availableNetworks = ["Cafe Guest", "Office"]
            return TrustedNetworksSettingsStore(
                initialState: state,
                dependencies: .init(
                    loadRules: { rules },
                    loadAvailableNetworks: { ["Cafe Guest", "Office"] },
                    saveRule: { _, _ in },
                    appDidBecomeActive: { AsyncStream { $0.finish() } },
                    enableKillSwitch: {},
                    showAddNetwork: {},
                    closeAddNetwork: {},
                )
            )
        }
    }
#endif

#Preview {
    TrustedNetworksSettingsView(store: .preview)
}
