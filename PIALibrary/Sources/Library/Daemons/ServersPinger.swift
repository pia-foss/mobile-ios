//
//  ServersPinger.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import SwiftyBeaver
import __PIALibraryNative

private let log = SwiftyBeaver.self

class ServersPinger: DatabaseAccess {
    static let shared = ServersPinger()

    private var pingQueues: [String: DispatchQueue] = [:]

    func ping(withDestinations destinations: [Server]) {
        let plainStore = accessedDatabase.plain

        var pingableServers: [Server] = []
        for server in destinations {
            guard let _ = server.pingAddress else {
                continue
            }
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

            let pingTimes = plainStore.pings(forServerIdentifier: server.identifier)
            let avgTime: Int?
            let capTime: Int?
            if let floatingAvgTime = pingTimes.avg() {
                avgTime = Int(floatingAvgTime)
                capTime = 2 * avgTime!
                log.verbose("Pinging \(server.identifier) (avg: \(avgTime!))")
            } else {
                avgTime = nil
                capTime = nil
                log.verbose("Pinging \(server.identifier) (no history)")
            }

            queue.async {
                guard var responseTime = server.ping(withProtocol: .UDP) else {
                    return
                }
                var isValid = false

                // discard biased pings
                if (self.accessedDatabase.transient.vpnStatus != .disconnected) {
                    log.warning("Discarded VPN-biased response from \(server.identifier): \(responseTime)")
                }
                // record highest (cap) on error/timeout, discard if no history
                else if (responseTime == .max) {
                    log.error("Error/timeout from \(server.identifier)")
                    if let capTime = capTime {
                        responseTime = capTime
                        isValid = true
                    }
                }
                else {
                    log.verbose("Response time from \(server.identifier): \(responseTime)")
                    if let capTime = capTime, (responseTime > capTime) {
                        responseTime = capTime
                        log.warning("Capped high response from \(server.identifier) to \(responseTime)")
                    }
                    isValid = true
                }

                DispatchQueue.main.sync {
                    if isValid {
                        plainStore.addPing(responseTime, forServerIdentifier: server.identifier)
                    }
                    remainingServers.remove(server)
                    if remainingServers.isEmpty {
                        plainStore.serializePings()
                        Macros.postNotification(.PIADaemonsDidPingServers)
                    }
                }
            }
        }
    }
}

extension Server {
    func ping(withProtocol protocolType: PingerProtocol) -> Int? {
        guard let address = pingAddress else {
            return nil
        }
        return Macros.ping(withProtocol: protocolType, hostname: address.hostname, port: address.port)
    }
}

