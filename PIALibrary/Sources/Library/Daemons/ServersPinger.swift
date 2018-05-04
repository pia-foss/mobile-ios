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

            log.verbose("Pinging \(server.identifier)")

            let completionBlock: (Int?) -> Void = { (time) in
                DispatchQueue.main.sync {
                    if let responseTime = time {
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
                guard let responseTime = server.ping(withProtocol: .UDP) else {
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

extension Server {
    func ping(withProtocol protocolType: PingerProtocol) -> Int? {
        guard let address = pingAddress else {
            return nil
        }
        return Macros.ping(withProtocol: protocolType, hostname: address.hostname, port: address.port)
    }
}

