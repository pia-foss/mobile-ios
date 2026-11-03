//
//  ForceUpdateStoreTests.swift
//  PIAForceUpdateTests
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

@testable import PIAForceUpdate

@MainActor
struct ForceUpdateStoreTests {

    private let spy = ForceUpdateDependencySpy()

    private func makeStore(
        state: ForceUpdate.State = ForceUpdate.State()
    ) -> TestStore<ForceUpdate.State, ForceUpdate.Action> {
        TestStore(
            initial: state,
            reduce: ForceUpdate.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    @Test("Appearing shows the hint when the VPN is connected", arguments: [true, false])
    func appearingReflectsVPNStatus(isConnected: Bool) async throws {
        spy.isVPNConnected = isConnected
        let sut = makeStore(state: .init(isVPNConnected: !isConnected))

        sut.send(.onAppear)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.isVPNConnected == isConnected)
    }

    @Test("Tapping update runs the update once per tap")
    func tappingUpdateRunsUpdate() async {
        let sut = makeStore()

        sut.send(.updateTapped)
        await sut.finish()

        #expect(spy.updateCallCount == 1)
        #expect(sut.state == ForceUpdate.State())
    }

    @Test("The live update uninstalls the VPN profiles before opening the App Store")
    func liveUpdateUninstallsThenOpensAppStore() {
        var calls: [String] = []
        let dependencies = ForceUpdate.Dependencies.live(
            isVPNConnected: { false },
            uninstallVPNProfiles: { calls.append("uninstall") },
            openURL: { calls.append("open \($0.absoluteString)") }
        )

        dependencies.update()

        #expect(
            calls == [
                "uninstall",
                "open https://itunes.apple.com/app/private-internet-access-anonymous/id955626407"
            ])
    }
}
