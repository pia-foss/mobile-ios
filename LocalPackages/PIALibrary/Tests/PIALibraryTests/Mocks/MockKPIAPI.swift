//
//  MockKPIAPI.swift
//  PIALibraryTests
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
import PIAKPI
import XCTest

/// Test double for `KPIAPI` that captures submitted events. Events are submitted from a
/// detached `Task` inside `ServiceQualityManager`, so tests fulfill `submitExpectation`
/// to await the submission before asserting.
final class MockKPIAPI: KPIAPI, @unchecked Sendable {

    private let lock = NSLock()
    private var storedEvents: [KPIClientEvent] = []
    private var submitExpectation: XCTestExpectation?

    var submittedEvents: [KPIClientEvent] {
        lock.lock()
        defer { lock.unlock() }
        return storedEvents
    }

    /// Fulfilled once for every `submit(event:)` call.
    func expectSubmission(_ expectation: XCTestExpectation) {
        lock.lock()
        defer { lock.unlock() }
        submitExpectation = expectation
    }

    func start() async {}
    func stop() async throws {}
    func flush() async throws {}
    func recentEvents() async -> [String] { [] }

    func submit(event: KPIClientEvent) async throws {
        lock.lock()
        storedEvents.append(event)
        let expectation = submitExpectation
        lock.unlock()
        expectation?.fulfill()
    }
}
