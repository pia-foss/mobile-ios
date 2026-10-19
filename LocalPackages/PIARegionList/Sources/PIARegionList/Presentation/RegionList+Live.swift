//
//  RegionList+Live.swift
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
import PIAFavorites
import PIALibrary
import PIALocalizations
import PIARegionListDomain

extension RegionList {
    /// App-level preferences the library doesn't own.
    public struct Preferences: Sendable {
        public var selectedID: @Sendable () -> ID
        public var sort: @Sendable () -> RegionFilter
        public var setSort: @Sendable (RegionFilter) -> Void
        public var showGeoServers: @Sendable () -> Bool

        public init(
            selectedID: @Sendable @escaping () -> ID,
            sort: @Sendable @escaping () -> RegionFilter,
            setSort: @Sendable @escaping (RegionFilter) -> Void,
            showGeoServers: @Sendable @escaping () -> Bool
        ) {
            self.selectedID = selectedID
            self.sort = sort
            self.setSort = setSort
            self.showGeoServers = showGeoServers
        }
    }
}

extension RegionList.Dependencies {

    public static func live(
        preferences: RegionList.Preferences,
        favorites: any FavoriteRegionUseCaseType & Sendable,
        progressResetDelay: TimeInterval,
        emit: @MainActor @escaping (RegionList.Output) -> Void
    ) -> RegionList.Dependencies {
        let vpnState: @Sendable () -> RegionList.VPNState = {
            RegionList.VPNState(Client.providers.vpnProvider.vpnStatus)
        }
        return RegionList.Dependencies(
            load: { loadContent(preferences: preferences, favorites: favorites) },
            vpnState: vpnState,
            vpnStateUpdates: {
                AsyncStream { continuation in
                    let task = Task {
                        for await _ in NotificationCenter.default.notifications(named: .PIADaemonsDidUpdateVPNStatus) {
                            continuation.yield(vpnState())
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            },
            setSort: preferences.setSort,
            setFavorite: { region, isFavorite in
                if isFavorite {
                    _ = try? favorites.addToFavorites(region.id.identifier, isDipServer: region.id.isDedicated)
                } else {
                    _ = try? favorites.removeFromFavorites(region.id.identifier, isDipServer: region.id.isDedicated)
                }
                NotificationCenter.default.post(name: .PIAServerHasBeenUpdated, object: nil)
            },
            ping: {
                await Client.ping(servers: Client.providers.serverProvider.currentServers) == .completed
            },
            progressResetDelay: progressResetDelay,
            emit: emit
        )
    }

    private static func loadContent(
        preferences: RegionList.Preferences,
        favorites: any FavoriteRegionUseCaseType
    ) -> RegionList.Content {
        let sort = preferences.sort()
        // Read the Keychain once: sorting and mapping ask about every server.
        let favoriteKeys = Set(favorites.favoriteIdentifiers)
        let isFavorite: (Server) -> Bool = { favoriteKeys.contains($0.favoriteKey) }
        let servers = RegionsSortUseCase()(
            Client.providers.serverProvider.currentServers.filter { $0.identifier != RegionList.ID.automatic.identifier },
            sort: sort,
            showGeoServers: preferences.showGeoServers(),
            vpnType: Client.providers.vpnProvider.currentVPNType,
            isFavorite: isFavorite
        )
        let dipTokens = Client.providers.serverProvider.dipTokens ?? []

        return RegionList.Content(
            automatic: RegionList.Region(id: .automatic, name: L10n.Global.automatic, country: "universal"),
            dedicated:
                servers
                .filter { $0.dipToken.map(dipTokens.contains) ?? false }
                .map { RegionList.Region($0, isFavorite: isFavorite($0)) },
            regions:
                servers
                .filter { $0.dipToken == nil }
                .map { RegionList.Region($0, isFavorite: isFavorite($0)) },
            selectedID: preferences.selectedID(),
            sort: sort
        )
    }
}

extension RegionList.VPNState {
    public init(_ status: VPNStatus) {
        switch status {
        case .connected: self = .connected
        case .disconnected: self = .disconnected
        default: self = .other
        }
    }
}

extension RegionList.Region {
    fileprivate init(_ server: Server, isFavorite: Bool) {
        let isDedicated = server.dipToken != nil
        self.init(
            id: RegionList.ID(identifier: server.identifier, isDedicated: isDedicated),
            name: server.name,
            country: server.country,
            isGeo: server.geo,
            isOffline: server.offline,
            pingTime: server.pingTime,
            dedicatedIP: isDedicated ? (server.wireGuardAddressesForUDP?.first?.ip ?? "") : nil,
            isFavorite: isFavorite
        )
    }
}
