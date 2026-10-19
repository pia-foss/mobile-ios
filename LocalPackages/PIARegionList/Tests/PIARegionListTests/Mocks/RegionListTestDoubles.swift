//
//  RegionListTestDoubles.swift
//  PIARegionListTests
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

@testable import PIARegionList

enum Stub {
    static let berlin = RegionList.Region(id: .init(identifier: "de-berlin", isDedicated: false), name: "DE Berlin", country: "DE", pingTime: 40)
    static let paris = RegionList.Region(id: .init(identifier: "fr", isDedicated: false), name: "France", country: "FR", pingTime: 120)
    static let offline = RegionList.Region(id: .init(identifier: "ca", isDedicated: false), name: "CA Montreal", country: "CA", isOffline: true)
    static let dedicated = RegionList.Region(
        id: .init(identifier: "de-berlin", isDedicated: true),
        name: "DE Berlin",
        country: "DE",
        dedicatedIP: "1.2.3.4"
    )
    static let automatic = RegionList.Region(id: .automatic, name: "Automatic", country: "universal")

    static func content(selectedID: RegionList.ID = .automatic, sort: RegionFilter = .latency) -> RegionList.Content {
        RegionList.Content(
            automatic: automatic,
            dedicated: [dedicated],
            regions: [berlin, paris, offline],
            selectedID: selectedID,
            sort: sort
        )
    }

    static func state(selectedID: RegionList.ID = .automatic, vpnState: RegionList.VPNState = .disconnected) -> RegionList.State {
        RegionList.State(content: content(selectedID: selectedID), vpnState: vpnState)
    }
}

final class DependencySpy: @unchecked Sendable {
    var content = Stub.content()
    var vpnState = RegionList.VPNState.disconnected
    var pingCompletes = true
    var vpnStates: [RegionList.VPNState] = []

    private(set) var sorts: [RegionFilter] = []
    private(set) var favorites: [(RegionList.ID, Bool)] = []
    private(set) var pingCallCount = 0
    private(set) var emittedOutputs: [RegionList.Output] = []

    func makeDependencies() -> RegionList.Dependencies {
        RegionList.Dependencies(
            load: { self.content },
            vpnState: { self.vpnState },
            vpnStateUpdates: {
                let states = self.vpnStates
                return AsyncStream { continuation in
                    states.forEach { continuation.yield($0) }
                    continuation.finish()
                }
            },
            setSort: { sort in
                self.sorts.append(sort)
                self.content.sort = sort
            },
            setFavorite: { region, isFavorite in self.favorites.append((region.id, isFavorite)) },
            ping: {
                self.pingCallCount += 1
                return self.pingCompletes
            },
            progressResetDelay: 0,
            emit: { self.emittedOutputs.append($0) }
        )
    }
}
