//
//  ICMPPing.swift
//  PIALibrary
//  
//  Created by Jose Antonio Blaya Garcia on 04/05/2020.
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

class ICMPPing: NSObject {
    
    private var ipAddress: String!
    private var completion: (Int?) -> ()

    private var pinger: SimplePing?
    private var sentTime: TimeInterval = 0
    private var timeoutTimer: Timer!

    init(ip: String, completionBlock: @escaping (Int?) -> ()) {
        self.completion = completionBlock
        self.ipAddress = ip
    }
    
    func start() {

        log.debug("Start pinging \(self.ipAddress)")
        let pinger = SimplePing(hostName: self.ipAddress)
        self.pinger = pinger
        pinger.addressStyle = .icmPv4
        pinger.delegate = self
        pinger.start()

    }
    
    func stop() {
        
        self.pinger?.stop()
        self.pinger = nil

    }

    /// Sends a ping.
    ///
    /// Called to send a ping, both directly (as soon as the SimplePing object starts up) and
    /// via a timer (to continue sending pings periodically).
    
    @objc func sendPing() {
        self.pinger!.send(with: nil)
        self.timeoutTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
    
    @objc func fireTimer() {
        log.debug("Timeout for \(ipAddress)")
        self.stop()
        self.timeoutTimer.invalidate()
        self.timeoutTimer = nil
        completion(nil)
    }

}

extension ICMPPing: SimplePingDelegate {
    
    // MARK: pinger delegate callback
    
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        self.sendPing()
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        completion(nil)
        self.stop()
    }
    
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        sentTime = Date().timeIntervalSince1970
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        completion(nil)
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        let latency = Int(((Date().timeIntervalSince1970 - sentTime).truncatingRemainder(dividingBy: 1)) * 1000)
        log.debug("SimplePing returned \(latency) MS for \(ipAddress)")
        completion(latency)
    }
    
    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
    }
    
}
