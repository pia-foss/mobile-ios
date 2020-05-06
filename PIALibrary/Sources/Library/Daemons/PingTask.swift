//
//  PingTask.swift
//  PIALibrary
//  
//  Created by Jose Antonio Blaya Garcia on 05/05/2020.
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

class PingTask {
    
    let identifier: String
    let server: Server
    let address: Server.Address
    let stateUpdateHandler: (PingTask) -> ()
    var state = PingTaskState.pending {
        didSet {
            self.stateUpdateHandler(self)
        }
    }

    init(identifier: String, server: Server, address: Server.Address, stateUpdateHandler: @escaping (PingTask) -> ()) {
        self.identifier = identifier
        self.server = server
        self.address = address
        self.stateUpdateHandler = stateUpdateHandler
    }
    
    func startTask(queue: DispatchQueue) {
        queue.async() { [weak self] in
                        
            var response: Int?
            let persistence = Client.database.plain
            self?.state = .pending

            guard let address = self?.address, let server = self?.server else {
                return
            }
            
            if Client.configuration.serverNetwork == .gen4 {
                self?.server.icmpPing(toAddress: address, withCompletion: { duration in
                    if Client.configuration.serverNetwork == .gen4 {
                        response = duration
                        self?.parsePingResponse(response: response, withServer: server)
                        if let responseTime = response {
                            DispatchQueue.main.async {
                                server.updateResponseTime(responseTime, forAddress: address)
                                persistence.setPing(responseTime, forServerIdentifier: server.identifier)
                            }
                        }
                    }
                    //Discard result if the server network changed waiting to the response
                    self?.state = .completed

                })
            } else {
                response = server.ping(toAddress: address, withProtocol: .UDP)
                self?.parsePingResponse(response: response, withServer: server)
                if let responseTime = response {
                    DispatchQueue.main.async {
                        server.updateResponseTime(responseTime, forAddress: address)
                        persistence.setPing(responseTime, forServerIdentifier: server.identifier)
                    }
                }
                self?.state = .completed
            }
            
        }
    }
    
    private func parsePingResponse(response: Int?, withServer server: Server) {
        
        guard let responseTime = response else {
            log.warning("Error/timeout from \(server.identifier)")
            return
        }

        // discard biased pings
        guard (Client.database.transient.vpnStatus == .disconnected) else {
            log.warning("Discarded VPN-biased response from \(server.identifier): \(responseTime)")
            return
        }

        log.debug("Response time from \(server.identifier): \(responseTime)")

    }

}

enum PingTaskState {
    
    case pending
    case completed
    
    var description: String {
        switch self {
        case .pending:
            return "Pending"
            
        case .completed:
            return "Completed"
            
        }
    
    }
}

extension Array where Element == PingTask {
    
    func indexOfTaskWith(identifier: String) -> Int? {
        return self.firstIndex { $0.identifier == identifier }
    }
}
