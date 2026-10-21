//
//  RegionListReducerTests.swift
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

import CoreArchitecture
import Foundation
import Testing

@testable import PIARegionList

@MainActor
struct RegionListReducerTests {
    private let sut = RegionList.Reducer(dependencies: DependencySpy().makeDependencies())

    @Test("Searching hides Automatic and filters both lists by name")
    func search() {
        // GIVEN the full list
        var state = Stub.state()

        // WHEN searching for "berlin"
        #expect(sut.reduce(&state, .searchChanged("berlin")) == nil)

        // THEN only the Berlin regions remain and Automatic is hidden
        #expect(state.visible.automatic == nil)
        #expect(state.visible.dedicated == [Stub.dedicated])
        #expect(state.visible.regions == [Stub.berlin])
        #expect(!state.visible.isEmpty)
    }

    @Test("A search without matches is empty")
    func emptySearch() {
        var state = Stub.state()
        _ = sut.reduce(&state, .searchChanged("tokyo"))
        #expect(state.visible.isEmpty)
    }

    @Test("Toggling a favorite updates the row in place")
    func favorite() {
        // GIVEN Berlin is not a favorite
        var state = Stub.state()

        // WHEN tapping its star
        let effect = sut.reduce(&state, .favoriteTapped(Stub.berlin.id))

        // THEN it is a favorite and the change is saved
        #expect(effect != nil)
        #expect(state.content.regions.first?.isFavorite == true)
        #expect(state.content.dedicated.first?.isFavorite == false)
    }

    @Test("Automatic and offline regions can't be favorited", arguments: [RegionList.ID.automatic, Stub.offline.id])
    func favoriteIgnored(id: RegionList.ID) {
        var state = Stub.state()
        #expect(sut.reduce(&state, .favoriteTapped(id)) == nil)
        #expect(state == Stub.state())
    }

    @Test("Tapping an offline region does nothing")
    func tapOffline() {
        var state = Stub.state()
        #expect(sut.reduce(&state, .regionTapped(Stub.offline.id)) == nil)
    }

    @Test(
        "Ping latency is only shown while disconnected",
        arguments: [
            (RegionList.VPNState.disconnected, true), (.connected, false), (.other, false)
        ])
    func showsPingTime(vpnState: RegionList.VPNState, expected: Bool) {
        var state = Stub.state()
        _ = sut.reduce(&state, .vpnStateChanged(vpnState))
        #expect(state.showsPingTime == expected)
        #expect(state.canRefresh == expected)
    }

    @Test("Refreshing starts pinging once")
    func refresh() {
        // GIVEN a disconnected VPN
        var state = Stub.state()

        // WHEN pulling to refresh twice
        #expect(sut.reduce(&state, .refreshTriggered) != nil)
        #expect(sut.reduce(&state, .refreshTriggered) == nil)

        // THEN it is pinging and can't refresh again
        #expect(state.pingPhase == .pinging)
        #expect(!state.canRefresh)
    }

    @Test("An interrupted ping resets the bar")
    func pingCancelled() {
        var state = Stub.state()
        state.pingPhase = .pinging
        #expect(sut.reduce(&state, .pingFinished(completed: false)) == nil)
        #expect(state.pingPhase == .idle)
    }

    @Test("A completed ping fills the bar")
    func pingCompleted() {
        var state = Stub.state()
        state.pingPhase = .pinging
        #expect(sut.reduce(&state, .pingFinished(completed: true)) != nil)
        #expect(state.pingPhase == .finished)
        _ = sut.reduce(&state, .progressReset)
        #expect(state.pingPhase == .idle)
    }
}
