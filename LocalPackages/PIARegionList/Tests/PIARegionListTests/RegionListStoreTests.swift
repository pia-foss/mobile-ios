//
//  RegionListStoreTests.swift
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
struct RegionListStoreTests {
    private let spy = DependencySpy()

    private func makeStore(state: RegionList.State = Stub.state()) -> TestStore<RegionList.State, RegionList.Action> {
        TestStore(initial: state, reduce: RegionList.Reducer(dependencies: spy.makeDependencies()).reduce)
    }

    @Test("Tapping a region selects it")
    func select() async {
        let sut = makeStore()
        sut.send(.regionTapped(Stub.paris.id))
        await sut.finish()
        #expect(spy.emittedOutputs == [.selected(Stub.paris.id)])
    }

    @Test("Tapping the current region while connected only dismisses")
    func tapCurrentWhileConnected() async {
        let sut = makeStore(state: Stub.state(selectedID: Stub.berlin.id, vpnState: .connected))
        sut.send(.regionTapped(Stub.berlin.id))
        await sut.finish()
        #expect(spy.emittedOutputs == [.dismiss])
    }

    @Test("Tapping the current region while disconnected still selects it")
    func tapCurrentWhileDisconnected() async {
        let sut = makeStore(state: Stub.state(selectedID: Stub.berlin.id))
        sut.send(.regionTapped(Stub.berlin.id))
        await sut.finish()
        #expect(spy.emittedOutputs == [.selected(Stub.berlin.id)])
    }

    @Test("Tapping a Dedicated IP selects the Dedicated IP, not the regular region")
    func selectDedicated() async {
        let sut = makeStore(state: Stub.state(selectedID: Stub.berlin.id, vpnState: .connected))
        sut.send(.regionTapped(Stub.dedicated.id))
        await sut.finish()
        #expect(spy.emittedOutputs == [.selected(Stub.dedicated.id)])
    }

    @Test("Refreshing while connected tells the host instead of pinging")
    func refreshWhileConnected() async {
        let sut = makeStore(state: Stub.state(vpnState: .connected))
        sut.send(.refreshTriggered)
        await sut.finish()
        #expect(spy.emittedOutputs == [.refreshUnavailableWhileConnected])
        #expect(spy.pingCallCount == 0)
        #expect(sut.state.pingPhase == .idle)
    }

    @Test("A completed ping reloads the regions and resets the bar")
    func pingReloads() async throws {
        // GIVEN new latencies after the ping
        let sut = makeStore()
        spy.content.regions = [Stub.paris, Stub.berlin]

        // WHEN refreshing
        sut.send(.refreshTriggered)

        // THEN it pings, reloads and resets the bar
        #expect(try #require(await sut.receive()) == .pingFinished(completed: true))
        var received = [try #require(await sut.receive()), try #require(await sut.receive())]
        received.sort { "\($0)" < "\($1)" }
        #expect(received == [.loaded(spy.content), .progressReset])
        #expect(spy.pingCallCount == 1)
        #expect(sut.state.content.regions == [Stub.paris, Stub.berlin])
        #expect(sut.state.pingPhase == .idle)
    }

    @Test("Changing the sort saves it and reloads")
    func sort() async throws {
        let sut = makeStore()
        sut.send(.sortSelected(.name))
        #expect(try #require(await sut.receive()) == .loaded(spy.content))
        #expect(spy.sorts == [.name])
        #expect(sut.state.content.sort == .name)
    }

    @Test("Favorites are saved for the tapped region")
    func favorite() async {
        let sut = makeStore()
        sut.send(.favoriteTapped(Stub.dedicated.id))
        await sut.finish()
        #expect(spy.favorites.map(\.0) == [Stub.dedicated.id])
        #expect(spy.favorites.map(\.1) == [true])
    }

    @Test("VPN state updates are applied after appearing")
    func vpnUpdates() async throws {
        spy.vpnStates = [.connected]
        let sut = makeStore()
        sut.send(.onAppear)
        #expect(try #require(await sut.receive()) == .vpnStateChanged(.connected))
        #expect(!sut.state.showsPingTime)
    }
}
