//
//  RegionRow.swift
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
    import PIAAssetsFlags
    import PIAAssetsMobile
    import PIALocalizations
    import SwiftUI

    struct RegionRow: View {
        let region: RegionList.Region
        let isAutomatic: Bool
        let isSelected: Bool
        let showsPingTime: Bool
        let toggleFavorite: () -> Void

        @Environment(\.colorScheme) private var colorScheme

        private var pingText: String? {
            guard !region.isOffline, showsPingTime, let pingTime = region.pingTime else { return nil }
            return "\(pingTime)ms"
        }

        var body: some View {
            let style = RegionListStyle(colorScheme: colorScheme)
            HStack(spacing: 0) {
                RegionFlag(country: region.country, isOffline: region.isOffline)
                    .padding(.leading, 14)
                    .padding(.trailing, 9)
                HStack(spacing: 10) {
                    Text(region.name)
                        .font(RegionListStyle.font(size: 14))
                        .foregroundColor(style.title)
                        .lineLimit(2)
                    icons
                }
                .opacity(region.isOffline ? 0.3 : 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(pingText ?? "")
                    .font(RegionListStyle.font(size: 12))
                    .foregroundColor(region.pingTime.map(RegionListStyle.pingColor) ?? style.title)
                    .padding(.leading, 1)
                    .layoutPriority(1)
                FavoriteButton(
                    isFavorite: region.isFavorite,
                    isOffline: region.isOffline,
                    isHidden: isAutomatic,
                    action: toggleFavorite
                )
                .padding(.leading, 5)
                .padding(.trailing, 5)
            }
            .frame(height: RegionListStyle.rowHeight)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(pingText.map { "\(region.name), \($0)" } ?? region.name)
        }

        @ViewBuilder
        private var icons: some View {
            if region.isGeo {
                Image(asset: isSelected ? Asset.iconGeoSelected : Asset.iconGeo)
                    .resizable()
                    .frame(width: 18, height: 18)
                Image(asset: Asset.Piax.Global.regionSelected)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .opacity(isSelected ? 1 : 0)
            } else {
                Image(asset: Asset.Piax.Global.regionSelected)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .opacity(isSelected ? 1 : 0)
                Color.clear.frame(width: 18, height: 18)
            }
        }
    }

    struct RegionFlag: View {
        let country: String
        var isOffline = false

        var body: some View {
            (Flag.swiftUIImage(forCountry: country) ?? Image(systemName: "globe"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .opacity(isOffline ? 0.3 : 1)
                .accessibilityHidden(true)
        }
    }

    struct FavoriteButton: View {
        let isFavorite: Bool
        var isOffline = false
        var isHidden = false
        let action: () -> Void

        @State private var scale: CGFloat = 1

        var body: some View {
            Button {
                action()
                withAnimation(.easeInOut(duration: RegionListStyle.animationDuration)) { scale = 1.2 }
                DispatchQueue.main.asyncAfter(deadline: .now() + RegionListStyle.animationDuration) {
                    withAnimation(.easeInOut(duration: 0.2)) { scale = 1 }
                }
            } label: {
                image
                    .resizable()
                    .frame(width: 17, height: 15)
                    .scaleEffect(scale)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isOffline || isHidden)
            .opacity(isHidden ? 0 : 1)
            .accessibilityHidden(isHidden)
            // Kept inverted: the E2E tests read "Add a favorite region" as "is a favorite".
            .accessibilityLabel(
                isOffline ? L10n.Global.disabled : (isFavorite ? L10n.Region.Accessibility.favorite : L10n.Region.Accessibility.unfavorite)
            )
        }

        private var image: Image {
            if isOffline { return Image(asset: Asset.offlineServerIcon) }
            return Image(asset: isFavorite ? Asset.Piax.Global.favoriteSelected : Asset.Piax.Global.favoriteUnselected)
        }
    }
#endif
