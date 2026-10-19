//
//  RegionsSortUseCase.swift
//  PIARegionListDomain
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
import PIALibrary

public protocol NamedRegion {
    var name: String { get }
}

/// What `RegionsSortUseCase` needs from a server.
public protocol SortableRegion: NamedRegion {
    var pingTime: Int? { get }
    var geo: Bool { get }
    var dipToken: String? { get }
    func hasEndpoints(for vpnType: String) -> Bool
}

extension Server: SortableRegion {}

/// The iOS region list ordering: sort, then hide geo servers and servers without endpoints for the protocol.
public struct RegionsSortUseCase: Sendable {
    public init() {}

    public func callAsFunction<Region: SortableRegion>(
        _ regions: [Region],
        sort: RegionFilter,
        showGeoServers: Bool,
        vpnType: String,
        isFavorite: (Region) -> Bool
    ) -> [Region] {
        sorted(regions, by: sort, isFavorite: isFavorite)
            .filter { showGeoServers || !$0.geo }
            .filter { ProtocolFilter.isReachable(dipToken: $0.dipToken, vpnType: vpnType, hasEndpoints: $0.hasEndpoints(for:)) }
    }

    public func search<Region: NamedRegion>(_ text: String, in regions: [Region]) -> [Region] {
        guard !text.isEmpty else { return regions }
        let text = text.lowercased()
        return regions.filter { $0.name.lowercased().contains(text) }
    }

    private func sorted<Region: SortableRegion>(_ regions: [Region], by sort: RegionFilter, isFavorite: (Region) -> Bool) -> [Region] {
        switch sort {
        case .name:
            return regions.sorted { $0.name < $1.name }
        case .latency:
            return regions.sorted { ($0.pingTime ?? .max) < ($1.pingTime ?? .max) }
        case .favorite:
            let byName = regions.sorted { $0.name < $1.name }
            return byName.filter(isFavorite) + byName.filter { !isFavorite($0) }
        }
    }
}
