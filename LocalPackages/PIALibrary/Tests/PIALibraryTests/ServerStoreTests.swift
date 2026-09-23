//
//  ServerStoreTests.swift
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
import Testing

@testable import PIALibrary

@Suite("ServerStore")
struct ServerStoreTests {

    // MARK: Basics

    @Test("Reads load from persistence once, then serve the copy")
    func readsLoadOnce() {
        let backing = Backing(servers: [makeServer(identifier: "a")])
        let store = backing.makeStore()

        #expect(store.read().count == 1)
        #expect(store.read().count == 1)
        #expect(backing.loadCount == 1)
    }

    @Test("Writes replace the list and persist it")
    func writesPersist() {
        let backing = Backing()
        let store = backing.makeStore()

        store.write([makeServer(identifier: "a"), makeServer(identifier: "b")])

        #expect(store.read().count == 2)
        #expect(backing.persisted.count == 2)
    }

    @Test("A mutation returning false neither writes nor persists")
    func skippedMutationDoesNotWrite() {
        let backing = Backing(servers: [makeServer(identifier: "a")])
        let store = backing.makeStore()

        let didWrite = store.mutate { servers in
            servers.append(makeServer(identifier: "b"))
            return false
        }

        #expect(didWrite == false)
        #expect(store.read().count == 1)
        #expect(backing.saveCount == 0)
    }

    @Test("Invalidating drops the copy so the next read goes back to persistence")
    func invalidateDropsTheCopy() {
        let backing = Backing(servers: [makeServer(identifier: "a")])
        let store = backing.makeStore()
        #expect(store.read().count == 1)

        backing.clear()
        store.invalidate()

        #expect(store.read().isEmpty)
    }

    // MARK: Concurrency

    /// The regression this store was written for: an append landing between a refresh's get and set.
    @Test("Concurrent mutations don't lose updates")
    func concurrentMutationsDoNotLoseUpdates() {
        let backing = Backing()
        let store = backing.makeStore()

        let writers = 64
        DispatchQueue.concurrentPerform(iterations: writers) { index in
            store.mutate { servers in
                servers.append(makeServer(identifier: "server_\(index)", dipToken: "token_\(index)"))
                return true
            }
        }

        #expect(store.read().count == writers)
        #expect(Set(store.read().compactMap(\.dipToken)).count == writers)
    }

    /// A refresh may or may not win against a dedicated IP append, but must never tear the list.
    @Test("A refresh racing a dedicated IP append never tears the list")
    func refreshRacingDedicatedIPAppendNeverTears() {
        let backing = Backing()
        let store = backing.makeStore()
        let refreshed = (0..<32).map { makeServer(identifier: "refreshed_\($0)") }

        let observed = Locked<[Int]>([])
        DispatchQueue.concurrentPerform(iterations: 64) { index in
            switch index % 3 {
            case 0:
                store.write(refreshed)
            case 1:
                store.mutate { servers in
                    guard !servers.contains(where: { $0.dipToken == "dip" }) else { return false }
                    servers.append(makeServer(identifier: "dedicated", dipToken: "dip"))
                    return true
                }
            default:
                // Collected and checked afterwards: Swift Testing can't attribute a failure here.
                observed.sync { $0.append(store.read().count) }
            }
        }

        // Every read saw a whole list: empty, the refresh, or the refresh plus the dedicated IP.
        #expect(observed.sync { $0 }.allSatisfy { [0, refreshed.count, refreshed.count + 1, 1].contains($0) })
        #expect(store.read().filter { $0.dipToken == "dip" }.count <= 1)
    }

    /// Whichever lands last wins, but the loser must not resurrect the removed server.
    @Test("Concurrent removals and appends of the same token settle consistently")
    func concurrentRemovalsAndAppendsSettle() {
        let backing = Backing()
        let store = backing.makeStore()

        DispatchQueue.concurrentPerform(iterations: 64) { index in
            if index.isMultiple(of: 2) {
                store.mutate { servers in
                    guard !servers.contains(where: { $0.dipToken == "dip" }) else { return false }
                    servers.append(makeServer(identifier: "dedicated", dipToken: "dip"))
                    return true
                }
            } else {
                store.mutate { servers in
                    let remaining = servers.filter { $0.dipToken != "dip" }
                    guard remaining.count != servers.count else { return false }
                    servers = remaining
                    return true
                }
            }
        }

        #expect(store.read().filter { $0.dipToken == "dip" }.count <= 1)
    }

    // MARK: Helpers

    private func makeServer(identifier: String, dipToken: String? = nil) -> Server {
        return Server(
            serial: "",
            name: identifier,
            country: "de",
            hostname: "\(identifier).invalid",
            pingAddress: nil,
            dipToken: dipToken,
            regionIdentifier: identifier
        )
    }

    /// `Mutex` takes a `Sendable` value and `Server` is not one, hence the lock.
    private final class Locked<Value>: @unchecked Sendable {
        private let lock = NSLock()
        private var value: Value

        init(_ value: Value) {
            self.value = value
        }

        func sync<T>(_ body: (inout Value) -> T) -> T {
            lock.lock()
            defer { lock.unlock() }
            return body(&value)
        }
    }

    /// Stands in for the `UserDefaults` backing, which a unit-test process cannot reach.
    private final class Backing {
        private struct State {
            var servers: [Server]
            var loads = 0
            var saves = 0
        }

        private let state: Locked<State>

        init(servers: [Server] = []) {
            self.state = Locked(State(servers: servers))
        }

        var persisted: [Server] { state.sync { $0.servers } }
        var loadCount: Int { state.sync { $0.loads } }
        var saveCount: Int { state.sync { $0.saves } }

        func clear() {
            state.sync { $0.servers = [] }
        }

        func makeStore() -> ServerStore {
            return ServerStore(
                load: { [state] in
                    state.sync {
                        $0.loads += 1; return $0.servers
                    }
                },
                save: { [state] servers in
                    state.sync {
                        $0.servers = servers; $0.saves += 1
                    }
                }
            )
        }
    }
}
