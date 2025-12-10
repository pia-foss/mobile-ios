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

@available(tvOS 17.0, *)
class PingTask {
    
    let timeout = 3000
    
    let identifier: String
    let server: Server
    let address: Server.ServerAddressIP
    let stateUpdateHandler: (PingTask) -> ()
    var state = PingTaskState.pending {
        didSet {
            self.stateUpdateHandler(self)
        }
    }

    init(identifier: String, server: Server, address: Server.ServerAddressIP, stateUpdateHandler: @escaping (PingTask) -> ()) {
        self.identifier = identifier
        self.server = server
        self.address = address
        self.stateUpdateHandler = stateUpdateHandler
    }
    
    func startTask(queue: DispatchQueue) {
                        
        var response: Int?
        let persistence = Client.database.plain
        self.state = .pending
        
        log.debug("Starting to Ping \(server.identifier) with address: \(address.ip)")
        
        queue.async() { [weak self] in

            guard let address = self?.address, let server = self?.server else {
                return
            }
            
            let tcpAddress = Server.Address(hostname: address.ip, port: 443)
            response = server.ping(toAddress: tcpAddress, withProtocol: .TCP)
            DispatchQueue.main.async {
                self?.parsePingResponse(response: response, withServer: server)
                if let responseTime = response {
                    server.updateResponseTime(responseTime, forAddress: address)
                    persistence.setPing(responseTime, forServerIdentifier: server.identifier)
                }
                self?.state = .completed
            }

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.state != .completed {
                self.parsePingResponse(response: self.timeout, withServer: self.server)
                self.server.updateResponseTime(self.timeout, forAddress: self.address)
                persistence.setPing(self.timeout, forServerIdentifier: self.server.identifier)
                self.state = .completed
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

@available(tvOS 17.0, *)
extension Array where Element == PingTask {
    
    func indexOfTaskWith(identifier: String) -> Int? {
        return self.firstIndex { $0.identifier == identifier }
    }
}
