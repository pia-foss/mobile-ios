//
//  RegionList+Derived.swift
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

import Foundation
import PIARegionListDomain

extension RegionList.Region: NamedRegion {}

extension RegionList {
    /// The lists the screen renders, filtered by the current search.
    ///
    /// Built in one go because the filter walks every region: asking `State` for each list
    /// separately would run it again each time.
    public struct Visible: Equatable {
        public let automatic: Region?
        public let dedicated: [Region]
        public let regions: [Region]

        public var isEmpty: Bool { automatic == nil && dedicated.isEmpty && regions.isEmpty }
    }
}

extension RegionList.State {
    public var isSearching: Bool { !searchText.isEmpty }

    public var visible: RegionList.Visible {
        let sorting = RegionsSortUseCase()
        return RegionList.Visible(
            // Automatic is hidden while searching.
            automatic: isSearching ? nil : content.automatic,
            dedicated: sorting.search(searchText, in: content.dedicated),
            regions: sorting.search(searchText, in: content.regions)
        )
    }

    /// Latency is only meaningful when measured off-VPN.
    public var showsPingTime: Bool { vpnState == .disconnected }

    public var canRefresh: Bool { pingPhase != .pinging && vpnState == .disconnected }

    func region(for id: RegionList.ID) -> RegionList.Region? {
        if id == content.automatic.id { return content.automatic }
        return (content.dedicated + content.regions).first { $0.id == id }
    }

    mutating func updateRegion(_ id: RegionList.ID, _ update: (inout RegionList.Region) -> Void) {
        if let index = content.dedicated.firstIndex(where: { $0.id == id }) {
            update(&content.dedicated[index])
        } else if let index = content.regions.firstIndex(where: { $0.id == id }) {
            update(&content.regions[index])
        }
    }
}
