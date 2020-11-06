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

    private var pendingPings: [PingTask] = []

    private var isPinging = false

    func ping(withDestinations destinations: [Server]) {
        
        guard (accessedDatabase.transient.vpnStatus == .disconnected) else {
            log.debug("Not pinging servers while on VPN, will try on next update")
            return
        }

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
        
        let dispatchQueue = DispatchQueue(label: "com.privateinternetaccess.ping-server", attributes: .concurrent)

        for server in pingableServers {

            log.verbose("Pinging \(server.identifier)")
            
            for address in server.addresses() {

                let pingTask = PingTask(identifier: server.identifier, server: server, address: address, stateUpdateHandler: { (task) in
                    
                    guard let index = self.pendingPings.indexOfTaskWith(identifier: server.identifier) else {
                        return
                    }
                    
                    switch task.state {
                    case .completed:
                        self.pendingPings.remove(at: index)
                        if self.pendingPings.isEmpty {
                            self.finish()
                        }
                    default:
                        break
                    }

                })
                pendingPings.append(pingTask)

            }

        }
        
        if pendingPings.count == 0 {
            self.finish()
        }
        
        pendingPings.forEach {
            $0.startTask(queue: dispatchQueue)
        }

    }
        
    func reset() {
        pendingPings.removeAll()
        isPinging = false
    }
    
    func finish() {
        DispatchQueue.main.async { [unowned self] in
            self.accessedDatabase.plain.serializePings()
            self.reset()
            Macros.postNotification(.PIADaemonsDidPingServers)
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

