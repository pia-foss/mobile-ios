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
import SwiftyBeaver
import __PIALibraryNative

private let log = SwiftyBeaver.self

class ServersPinger: DatabaseAccess {
    static let shared = ServersPinger()

    private var pingQueues: [String: DispatchQueue] = [:]
    
    private var isPinging = false

    func ping(withDestinations destinations: [Server]) {
        guard !isPinging else {
            log.warning("Skip pinging, latest attempt still pending completion")
            return
        }
        
        isPinging = true

        let persistence = accessedDatabase.plain
        persistence.clearPings()
        
        var pingableServers: [Server] = []
        for server in destinations {
            pingableServers.append(server)
        }
        var remainingServers: Set<Server> = Set(pingableServers)

        for server in pingableServers {
            let queue: DispatchQueue
            if let existingQueue = pingQueues[server.identifier] {
                queue = existingQueue
            } else {
                queue = DispatchQueue(label: "ServersPinger-\(server.identifier)")
                pingQueues[server.identifier] = queue
            }

            log.verbose("Pinging \(server.identifier)")

            for address in server.bestPingAddress() {
                let completionBlock: (Int?) -> Void = { (time) in
                    DispatchQueue.main.sync {
                        if let responseTime = time {
                            server.updateResponseTime(responseTime, forAddress: address)
                            persistence.setPing(responseTime, forServerIdentifier: server.identifier)
                        }
                        remainingServers.remove(server)
                        if remainingServers.isEmpty {
                            persistence.serializePings()
                            self.isPinging = false
                            Macros.postNotification(.PIADaemonsDidPingServers)
                        }
                    }
                }

                queue.async {
                    guard let responseTime = server.ping(toAddress: address, withProtocol: .UDP) else {
                        log.warning("Error/timeout from \(server.identifier)")
                        completionBlock(nil)
                        return
                    }

                    // discard biased pings
                    guard (self.accessedDatabase.transient.vpnStatus == .disconnected) else {
                        log.warning("Discarded VPN-biased response from \(server.identifier): \(responseTime)")
                        completionBlock(nil)
                        return
                    }

                    log.debug("Response time from \(server.identifier): \(responseTime)")
                    completionBlock(responseTime)
                }

            }
        }
    }
}

extension Server {
    
    func ping(toAddress address:Address, withProtocol protocolType: PingerProtocol) -> Int? {
        return Macros.ping(withProtocol: protocolType, hostname: address.hostname, port: address.port)
    }
    
    func ping(withProtocol protocolType: PingerProtocol) -> Int? {
        guard let address = pingAddress else {
            return nil
        }
        return Macros.ping(withProtocol: protocolType, hostname: address.hostname, port: address.port)
    }
}

