//
//  ServersDaemonTests.swift
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

import XCTest

@testable import PIALibrary

final class ServersDaemonTests: XCTestCase {

    override func setUp() {
        super.setUp()

        Client.database.transient.isNetworkReachable = true
        Client.database.transient.vpnStatus = .disconnected
        // Pings are exercised by ServersPingerTests; keep them out of the cadence assertions.
        Client.configuration.enablesServerPings = false
    }

    override func tearDown() {
        Client.database.transient.isNetworkReachable = true
        Client.database.transient.vpnStatus = .disconnected
        super.tearDown()
    }

    private var pollIntervalNanoseconds: UInt64 {
        UInt64(Client.database.transient.serversConfiguration.pollInterval) * NSEC_PER_MSEC
    }

    /// Regression for KM-17628: `scheduleServersUpdate(withDelay:)` used to recreate an
    /// unsynchronized `DispatchSourceTimer` from every one of these call sites, and racing threads
    /// released a source that had not been resumed yet — `EXC_BREAKPOINT` inside libdispatch.
    /// Hammering the daemon from many tasks at once must neither trap nor start a second download.
    func testConcurrentWakeSignalsDoNotRaceOrDuplicateDownloads() async {
        let downloads = Counter()
        let sleeps = SleepRecorder(honorRequestedDelay: false)
        let daemon = ServersDaemon(
            downloadServers: {
                await downloadStub(downloads, delay: 200_000_000)
            },
            sleep: { await sleeps.record($0) }
        )

        daemon.start()
        daemon.enableUpdates()
        _ = await waitUntil { await downloads.invocations >= 1 }

        // Five concurrent producers, mirroring the notification paths that used to re-enter the
        // scheduler concurrently.
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    for _ in 0..<40 {
                        Macros.postNotification(.ConnectivityDaemonDidGetReachable)
                        Macros.postNotification(.PIADaemonsDidUpdateVPNStatus)
                        await Task.yield()
                    }
                }
            }
        }

        _ = await waitUntil { await sleeps.delays.count >= 2 }
        await daemon.reset()

        // The list is not stale again yet, so all that hammering must not have refetched it.
        let invocations = await downloads.invocations
        XCTAssertEqual(invocations, 1)
    }

    func testFirstRunDownloadsImmediatelyThenWaitsAPollInterval() async {
        let downloads = Counter()
        let sleeps = SleepRecorder(honorRequestedDelay: false)
        let daemon = ServersDaemon(
            downloadServers: { await downloadStub(downloads) },
            sleep: { await sleeps.record($0) }
        )

        daemon.enableUpdates()
        let recorded = await waitUntil { await sleeps.delays.count >= 1 }
        await daemon.reset()

        XCTAssertTrue(recorded)
        let invocations = await downloads.invocations
        XCTAssertEqual(invocations, 1)
        let delays = await sleeps.delays
        XCTAssertEqual(delays.first, pollIntervalNanoseconds)
    }

    func testNotYetStaleWaitsOnlyTheRemainingInterval() async {
        let downloads = Counter()
        let sleeps = SleepRecorder(honorRequestedDelay: false)
        let daemon = ServersDaemon(
            downloadServers: { await downloadStub(downloads) },
            sleep: { await sleeps.record($0) }
        )

        daemon.enableUpdates()
        _ = await waitUntil { await sleeps.delays.count >= 2 }
        await daemon.reset()

        // Second pass finds the list fresh, so it waits the remainder rather than a full interval
        // and does not download again.
        let delays = await sleeps.delays
        XCTAssertGreaterThan(delays.count, 1)
        XCTAssertLessThanOrEqual(delays[1], pollIntervalNanoseconds)
        let invocations = await downloads.invocations
        XCTAssertEqual(invocations, 1)
    }

    func testNetworkDownSkipsDownloadAndUsesConfiguredDelay() async {
        Client.database.transient.isNetworkReachable = false

        let downloads = Counter()
        let sleeps = SleepRecorder(honorRequestedDelay: false)
        let daemon = ServersDaemon(
            downloadServers: { await downloadStub(downloads) },
            sleep: { await sleeps.record($0) }
        )

        daemon.enableUpdates()
        _ = await waitUntil { await sleeps.delays.count >= 1 }
        await daemon.reset()

        let delays = await sleeps.delays
        XCTAssertEqual(
            delays.first,
            UInt64(Client.configuration.serversUpdateWhenNetworkDownDelay) * NSEC_PER_MSEC
        )
        let invocations = await downloads.invocations
        XCTAssertEqual(invocations, 0)
    }

    func testWakeSignalEndsTheCurrentSleepEarly() async {
        let downloads = Counter()
        // Honors the requested delay, so without a wake the loop would park for a full
        // poll interval (ten minutes by default).
        let sleeps = SleepRecorder(honorRequestedDelay: true)
        let daemon = ServersDaemon(
            downloadServers: { await downloadStub(downloads) },
            sleep: { await sleeps.record($0) }
        )

        daemon.start()
        daemon.enableUpdates()
        let sleeping = await waitUntil { await sleeps.delays.count >= 1 }
        XCTAssertTrue(sleeping)

        Macros.postNotification(.ConnectivityDaemonDidGetReachable)

        let wokeUp = await waitUntil(timeout: 3) { await sleeps.delays.count >= 2 }
        await daemon.reset()

        XCTAssertTrue(wokeUp, "wake() should have cancelled the in-progress sleep")
    }

    func testFailedDownloadStillReschedules() async {
        let downloads = Counter()
        let sleeps = SleepRecorder(honorRequestedDelay: false)
        let daemon = ServersDaemon(
            downloadServers: {
                await downloads.increment()
                return (nil, ClientError.malformedResponseData)
            },
            sleep: { await sleeps.record($0) }
        )

        daemon.enableUpdates()
        let rescheduled = await waitUntil { await sleeps.delays.count >= 1 }
        await daemon.reset()

        // A failure must not silently stop the cadence.
        XCTAssertTrue(rescheduled)
        let invocations = await downloads.invocations
        XCTAssertEqual(invocations, 1)
    }

    /// A download that never calls back must not wedge the loop. The watchdog has to abandon it
    /// rather than wait for it, so the cadence keeps running.
    func testHungDownloadDoesNotWedgeTheLoop() async {
        let sleeps = SleepRecorder(honorRequestedDelay: false)
        let daemon = ServersDaemon(
            downloadServers: {
                // Suspends forever and ignores cancellation, like a provider that drops its callback.
                await withCheckedContinuation { (_: CheckedContinuation<Void, Never>) in }
                return (nil, nil)
            },
            sleep: { await sleeps.record($0) },
            downloadTimeout: 50_000_000
        )

        daemon.enableUpdates()
        let rescheduled = await waitUntil(timeout: 3) { await sleeps.delays.count >= 1 }
        await daemon.reset()

        XCTAssertTrue(rescheduled, "the watchdog did not release the loop")
    }

    func testForceUpdatesReportsTheWatchdogTimeout() async {
        let daemon = ServersDaemon(
            downloadServers: {
                await withCheckedContinuation { (_: CheckedContinuation<Void, Never>) in }
                return (nil, nil)
            },
            sleep: { _ in },
            downloadTimeout: 50_000_000
        )

        do {
            try await daemon.forceUpdates()
            XCTFail("expected forceUpdates() to throw the watchdog error")
        } catch {
            XCTAssertNotNil(error as? ClientError)
        }
        await daemon.reset()
    }

    func testResetStopsTheLoop() async {
        let sleeps = SleepRecorder(honorRequestedDelay: false)
        let daemon = ServersDaemon(
            downloadServers: { (makeServers(count: 1), nil) },
            sleep: { await sleeps.record($0) }
        )

        daemon.enableUpdates()
        _ = await waitUntil { await sleeps.delays.count >= 1 }
        await daemon.reset()

        // Let any iteration that was already past its cancellation check finish before sampling.
        try? await Task.sleep(nanoseconds: 100_000_000)
        let afterReset = await sleeps.delays.count
        try? await Task.sleep(nanoseconds: 200_000_000)
        let settled = await sleeps.delays.count

        XCTAssertEqual(settled, afterReset, "the loop kept running after reset()")
    }

    func testForceUpdatesThrowsTheDownloadError() async {
        let daemon = ServersDaemon(
            downloadServers: { (nil, ClientError.malformedResponseData) },
            sleep: { _ in }
        )

        do {
            try await daemon.forceUpdates()
            XCTFail("expected forceUpdates() to throw")
        } catch {
            XCTAssertEqual(error as? ClientError, .malformedResponseData)
        }
        await daemon.reset()
    }

    func testForceUpdatesSucceedsWhenTheDownloadSucceeds() async {
        let daemon = ServersDaemon(
            downloadServers: { (makeServers(count: 2), nil) },
            sleep: { _ in }
        )

        do {
            try await daemon.forceUpdates()
        } catch {
            XCTFail("unexpected error: \(error)")
        }
        await daemon.reset()
    }
}

private func makeServers(count: Int) -> [Server] {
    return (0..<count).map { index in
        Server(
            serial: "serial-\(index)",
            name: "Server \(index)",
            country: "us",
            hostname: "server\(index).example.com",
            iKEv2AddressesForUDP: [Server.ServerAddressIP(ip: "10.0.0.\(index)", cn: "cn", van: false)],
            pingAddress: nil,
            regionIdentifier: "region-\(index)"
        )
    }
}

private func downloadStub(
    _ counter: Counter,
    delay: UInt64 = 0
) async -> ServersDaemon.DownloadResult {
    await counter.increment()
    if delay > 0 {
        try? await Task.sleep(nanoseconds: delay)
    }
    return (makeServers(count: 1), nil)
}

private func waitUntil(
    timeout: TimeInterval = 2,
    _ condition: @escaping () async -> Bool
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if await condition() {
            return true
        }
        try? await Task.sleep(nanoseconds: 5_000_000)
    }
    return await condition()
}

private actor Counter {
    private(set) var invocations = 0

    func increment() {
        invocations += 1
    }
}

private actor SleepRecorder {
    private(set) var delays: [UInt64] = []
    private let honorRequestedDelay: Bool

    init(honorRequestedDelay: Bool) {
        self.honorRequestedDelay = honorRequestedDelay
    }

    func record(_ nanoseconds: UInt64) async {
        delays.append(nanoseconds)
        if honorRequestedDelay {
            try? await Task.sleep(nanoseconds: nanoseconds)
        } else {
            await Task.yield()
        }
    }
}
