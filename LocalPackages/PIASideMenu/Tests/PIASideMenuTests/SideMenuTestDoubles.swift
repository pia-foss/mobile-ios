//
//  SideMenuTestDoubles.swift
//  PIASideMenuTests
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

@testable import PIASideMenu

@MainActor
final class SideMenuDependencySpy {
    var account: SideMenu.Account = .stub()
    var renewalResult: SideMenu.RenewalResult = .renewed
    private(set) var renewCallCount = 0
    private(set) var logoutCallCount = 0
    private(set) var emittedOutputs: [SideMenu.Output] = []

    /// Each `yield()` is one account update. Buffered, so a test can yield before the stream
    /// effect starts listening.
    let updates: AsyncStream<Void>.Continuation
    private let updateStream: AsyncStream<Void>

    init() {
        (updateStream, updates) = AsyncStream.makeStream()
    }

    func makeDependencies() -> SideMenu.Dependencies {
        .init(
            currentAccount: { [self] in account },
            accountUpdates: { [updateStream] in updateStream },
            renew: { [self] in
                renewCallCount += 1
                return renewalResult
            },
            logout: { [self] in logoutCallCount += 1 },
            emit: { [self] in emittedOutputs.append($0) }
        )
    }
}

extension SideMenu.Account {
    static func stub(username: String = "p1234567", expiration: SideMenu.Expiration? = nil) -> Self {
        .init(username: username, managedPlan: .yearly, expiration: expiration)
    }
}
