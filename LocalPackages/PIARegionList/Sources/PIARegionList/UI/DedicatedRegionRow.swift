//
//  DedicatedRegionRow.swift
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
    import SwiftUI

    struct DedicatedRegionRow: View {
        let region: RegionList.Region
        let isSelected: Bool
        let toggleFavorite: () -> Void

        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            let style = RegionListStyle(colorScheme: colorScheme)
            HStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    RegionFlag(country: region.country)
                    Image(asset: Asset.dipBadge)
                        .resizable()
                        .frame(width: 12, height: 12)
                        .offset(x: 23, y: 1)
                        .accessibilityHidden(true)
                }
                .padding(.leading, 14)
                .padding(.trailing, 9)

                VStack(alignment: .leading, spacing: 0) {
                    Text(region.name)
                        .font(RegionListStyle.font(size: 14))
                        .foregroundColor(style.title)

                    HStack(spacing: 10) {
                        if let dedicatedIP = region.dedicatedIP {
                            Text(dedicatedIP)
                                .font(RegionListStyle.font(size: 12))
                                .foregroundColor(style.secondary)
                                .lineLimit(1)
                        }
                        Text(L10n.Dedicated.Ip.title.uppercased())
                            .accessibilityLabel(L10n.Dedicated.Ip.title)
                            .font(RegionListStyle.font(size: 10))
                            .foregroundColor(style.secondary)
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style.secondary, lineWidth: 0.5)
                            )
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(asset: Asset.Piax.Global.regionSelected)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .opacity(isSelected ? 1 : 0)
                    .padding(.horizontal, 10)

                FavoriteButton(isFavorite: region.isFavorite, action: toggleFavorite)
                    .padding(.horizontal, 5)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(region.name)
        }
    }
#endif
