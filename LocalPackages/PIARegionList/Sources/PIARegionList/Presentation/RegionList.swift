//
//  RegionList.swift
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

public enum RegionList {}

extension RegionList {

    public struct ID: Hashable, Sendable {
        public let identifier: String
        public let isDedicated: Bool

        public init(identifier: String, isDedicated: Bool) {
            self.identifier = identifier
            self.isDedicated = isDedicated
        }
    }

    /// A server, reduced to what a row shows.
    public struct Region: Equatable, Identifiable, Sendable {
        public let id: ID
        public let name: String
        public let country: String
        public let isGeo: Bool
        public let isOffline: Bool
        public let pingTime: Int?
        /// The Dedicated IP address, only for Dedicated IP regions.
        public let dedicatedIP: String?
        public var isFavorite: Bool

        public init(
            id: ID,
            name: String,
            country: String,
            isGeo: Bool = false,
            isOffline: Bool = false,
            pingTime: Int? = nil,
            dedicatedIP: String? = nil,
            isFavorite: Bool = false
        ) {
            self.id = id
            self.name = name
            self.country = country
            self.isGeo = isGeo
            self.isOffline = isOffline
            self.pingTime = pingTime
            self.dedicatedIP = dedicatedIP
            self.isFavorite = isFavorite
        }
    }

    public enum VPNState: Equatable, Sendable {
        case connected
        case disconnected
        case other
    }

    /// Everything loaded from the providers, already sorted and filtered.
    public struct Content: Equatable, Sendable {
        public var automatic: Region
        public var dedicated: [Region]
        public var regions: [Region]
        public var selectedID: ID
        public var sort: RegionFilter

        public init(automatic: Region, dedicated: [Region], regions: [Region], selectedID: ID, sort: RegionFilter) {
            self.automatic = automatic
            self.dedicated = dedicated
            self.regions = regions
            self.selectedID = selectedID
            self.sort = sort
        }
    }

    public enum PingPhase: Equatable, Sendable {
        case idle
        case pinging
        /// The bar is full and about to reset.
        case finished
    }

    public struct State: Equatable {
        public var content: Content
        public var vpnState: VPNState
        public var searchText = ""
        public var pingPhase = PingPhase.idle

        public init(content: Content, vpnState: VPNState) {
            self.content = content
            self.vpnState = vpnState
        }
    }

    public enum Action: Equatable {
        case onAppear
        case vpnStateChanged(VPNState)
        case loaded(Content)
        case sortSelected(RegionFilter)
        case searchChanged(String)
        case favoriteTapped(ID)
        case regionTapped(ID)
        case refreshTriggered
        case pingFinished(completed: Bool)
        case progressReset
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        case selected(ID)
        case dismiss
        /// Latency can't be refreshed while the VPN is on.
        case refreshUnavailableWhileConnected
    }

    public struct Dependencies: Sendable {
        public var load: @Sendable () -> Content
        public var vpnState: @Sendable () -> VPNState
        public var vpnStateUpdates: @Sendable () -> AsyncStream<VPNState>
        public var setSort: @Sendable (RegionFilter) -> Void
        public var setFavorite: @Sendable (Region, Bool) -> Void
        /// Pings every server; `true` when the pass completed.
        public var ping: @Sendable () async -> Bool
        public var progressResetDelay: TimeInterval
        public var emit: @MainActor (Output) -> Void

        public init(
            load: @Sendable @escaping () -> Content,
            vpnState: @Sendable @escaping () -> VPNState,
            vpnStateUpdates: @Sendable @escaping () -> AsyncStream<VPNState>,
            setSort: @Sendable @escaping (RegionFilter) -> Void,
            setFavorite: @Sendable @escaping (Region, Bool) -> Void,
            ping: @Sendable @escaping () async -> Bool,
            progressResetDelay: TimeInterval,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.load = load
            self.vpnState = vpnState
            self.vpnStateUpdates = vpnStateUpdates
            self.setSort = setSort
            self.setFavorite = setFavorite
            self.ping = ping
            self.progressResetDelay = progressResetDelay
            self.emit = emit
        }
    }
}

extension RegionList.ID {
    public static let automatic = RegionList.ID(identifier: "auto", isDedicated: false)
}
