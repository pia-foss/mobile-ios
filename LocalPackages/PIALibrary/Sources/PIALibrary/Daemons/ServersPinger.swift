//
//  ServersPinger.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2020 Private Internet Access, Inc.
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

private let log = PIALogger.logger(for: ServersPinger.self)

actor ServersPinger: DatabaseAccess {
    static let shared = ServersPinger()

    private var isPinging = false

    func ping(withDestinations destinations: [Server]) async {
        guard accessedDatabase.transient.vpnStatus == .disconnected else {
            log.debug("Not pinging servers while on VPN, will try on next update")
            return
        }

        guard !isPinging else {
            log.warning("Skip pinging, latest attempt still pending completion")
            return
        }

        isPinging = true
        accessedDatabase.plain.clearPings()

        await withTaskGroup(of: Void.self) { group in
            for server in destinations {
                log.debug("Pinging \(server.identifier)")
                for address in server.addresses() {
                    group.addTask {
                        await self.pingServer(server, address: address)
                    }
                }
            }
        }

        finish()
    }

    private func pingServer(_ server: Server, address: Server.ServerAddressIP) async {
        log.debug("Starting to Ping \(server.identifier) with address: \(address.ip)")

        let tcpAddress = Server.Address(hostname: address.ip, port: 443)
        let responseTime = await pingWithTimeout(server: server, address: tcpAddress)

        // Discards results where VPN connected during the ping.
        guard accessedDatabase.transient.vpnStatus == .disconnected else {
            log.warning("Discarded VPN-biased response from \(server.identifier): \(responseTime)")
            return
        }

        log.debug("Response time from \(server.identifier): \(responseTime)")
        server.updateResponseTime(responseTime, forAddress: address)
        accessedDatabase.plain.setPing(responseTime, forServerIdentifier: server.identifier)
    }

    // Races the TCP ping against a 3-second deadline, returning whichever resolves first.
    private func pingWithTimeout(server: Server, address: Server.Address) async -> Int {
        let timeoutMs = 3000
        return await withTaskGroup(of: Int.self) { group in
            group.addTask {
                let result = server.ping(toAddress: address, withProtocol: .TCP)
                if result == nil {
                    log.warning("Error/timeout from \(server.identifier)")
                }
                return result ?? timeoutMs
            }

            group.addTask {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                return timeoutMs
            }

            let first = await group.next() ?? timeoutMs
            group.cancelAll()
            return first
        }
    }

    func reset() {
        isPinging = false
    }

    private func finish() {
        isPinging = false
        accessedDatabase.plain.serializePings()

        Task { @MainActor in
            Macros.postNotification(.PIADaemonsDidPingServers)
        }
    }
}

extension Server {

    func ping(toAddress address: Address, withProtocol protocolType: PingerProtocol) -> Int? {
        return Macros.ping(withProtocol: protocolType, hostname: address.hostname, port: address.port)
    }

    func ping(withProtocol protocolType: PingerProtocol) -> Int? {
        guard let address = pingAddress else {
            return nil
        }
        return Macros.ping(withProtocol: protocolType, hostname: address.hostname, port: address.port)
    }

}
