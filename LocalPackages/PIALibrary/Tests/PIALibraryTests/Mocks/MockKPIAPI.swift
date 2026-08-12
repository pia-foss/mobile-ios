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
/// detached `Task` inside `ServiceQualityManager`, so tests await one of the expectations
/// below before asserting.
final class MockKPIAPI: KPIAPI, @unchecked Sendable {

    private let lock = NSLock()
    private var storedEvents: [KPIClientEvent] = []
    private var submitExpectation: XCTestExpectation?

    var submittedEvents: [KPIClientEvent] {
        lock.lock()
        defer { lock.unlock() }
        return storedEvents
    }

    /// Returns an expectation fulfilled once per `submit(event:)` call and satisfied by
    /// exactly `count` of them. A further submission over-fulfills it and fails the test,
    /// so an unexpected extra event cannot pass unnoticed.
    func expectSubmissions(_ count: Int = 1) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "\(count) event(s) submitted")
        expectation.expectedFulfillmentCount = count
        return storing(expectation)
    }

    /// Returns an inverted expectation that fails if any event is submitted.
    func expectNoSubmission() -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "no event submitted")
        expectation.isInverted = true
        return storing(expectation)
    }

    private func storing(_ expectation: XCTestExpectation) -> XCTestExpectation {
        lock.lock()
        defer { lock.unlock() }
        submitExpectation = expectation
        return expectation
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
