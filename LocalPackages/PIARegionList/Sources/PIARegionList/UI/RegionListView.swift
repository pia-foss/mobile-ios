//
//  RegionListView.swift
//  PIARegionList
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

#if os(iOS)
    import PIAAssetsMobile
    import PIALocalizations
    import PIASwiftUI
    import SwiftUI

    /// The region list. The host owns the navigation bar: title, search and the sort menu.
    public struct RegionListView: View, ViewWithTitle {
        @ObservedObject private var store: RegionListStore
        @Environment(\.colorScheme) private var colorScheme

        public init(store: RegionListStore) {
            self.store = store
        }

        public var navigationTitle: String { L10n.Menu.Item.region }

        private enum RowID: Hashable {
            case top
            case automaticDivider
            case dedicatedDivider
        }

        public var body: some View {
            let state = store.state
            let visible = state.visible
            let style = RegionListStyle(colorScheme: colorScheme)
            ScrollViewReader { proxy in
                List {
                    Color.clear.frame(height: 0).listRow(style: style, separator: false).id(RowID.top)
                    if let automatic = visible.automatic {
                        RegionRow(
                            region: automatic,
                            isAutomatic: true,
                            isSelected: automatic.id == state.content.selectedID,
                            showsPingTime: state.showsPingTime,
                            toggleFavorite: {}
                        )
                        .tappableRow(style: style) { store.send(.regionTapped(automatic.id)) }
                        .id(automatic.id)
                        SectionDivider(style: style).id(RowID.automaticDivider)
                    }
                    ForEach(visible.dedicated) { region in
                        DedicatedRegionRow(
                            region: region,
                            isSelected: region.id == state.content.selectedID,
                            toggleFavorite: { store.send(.favoriteTapped(region.id)) }
                        )
                        .tappableRow(style: style) { store.send(.regionTapped(region.id)) }
                        .id(region.id)
                    }
                    if !visible.dedicated.isEmpty {
                        SectionDivider(style: style).id(RowID.dedicatedDivider)
                    }
                    ForEach(visible.regions) { region in
                        RegionRow(
                            region: region,
                            isAutomatic: false,
                            isSelected: region.id == state.content.selectedID,
                            showsPingTime: state.showsPingTime,
                            toggleFavorite: { store.send(.favoriteTapped(region.id)) }
                        )
                        .tappableRow(style: style, isEnabled: !region.isOffline) { store.send(.regionTapped(region.id)) }
                        .id(region.id)
                    }
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 0)
                .modifier(ListBackground(color: style.background))
                .overlay(alignment: .top) { PingProgressBar(phase: state.pingPhase) }
                .overlay {
                    if visible.isEmpty {
                        Image(asset: Asset.Piax.Regions.noResults)
                            .accessibilityIdentifier("empty set background image")
                    }
                }
                .modifier(PullToRefresh(isEnabled: state.vpnState == .disconnected) { store.send(.refreshTriggered) })
                .onAppear { scrollToSelection(proxy) }
                .onReceive(store.$state.map(\.content.sort).removeDuplicates().dropFirst()) { _ in
                    withAnimation { proxy.scrollTo(RowID.top, anchor: .top) }
                }
            }
            .task { store.send(.onAppear) }
        }

        private func scrollToSelection(_ proxy: ScrollViewProxy) {
            let id = store.state.content.selectedID
            if id == .automatic {
                proxy.scrollTo(RowID.top, anchor: .top)
            } else {
                proxy.scrollTo(id, anchor: id.isDedicated ? .top : .center)
            }
        }
    }

    private struct SectionDivider: View {
        let style: RegionListStyle

        var body: some View {
            style.divider
                .frame(height: 2)
                .listRow(style: style, separator: false)
                .accessibilityHidden(true)
        }
    }

    extension View {
        fileprivate func listRow(style: RegionListStyle, separator: Bool = true) -> some View {
            self
                .overlay(alignment: .bottom) {
                    if separator {
                        style.divider.frame(height: 0.5)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(style.background)
                .listRowSeparator(.hidden)
        }

        fileprivate func tappableRow(style: RegionListStyle, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
            self
                .contentShape(Rectangle())
                .onTapGesture(perform: action)
                .allowsHitTesting(isEnabled)
                .accessibilityAddTraits(.isButton)
                .accessibilityAction(.default, action)
                .accessibilityIdentifier("uitests.regions.region_name")
                .listRow(style: style)
        }
    }

    private struct ListBackground: ViewModifier {
        let color: Color

        func body(content: Content) -> some View {
            if #available(iOS 16.0, *) {
                content.scrollContentBackground(.hidden).background(color)
            } else {
                content.background(color)
            }
        }
    }

    private struct PullToRefresh: ViewModifier {
        let isEnabled: Bool
        let action: () -> Void

        func body(content: Content) -> some View {
            #if targetEnvironment(macCatalyst)
                content
            #else
                if isEnabled {
                    content.refreshable { action() }
                } else {
                    content
                }
            #endif
        }
    }
#endif
