//
//  WGPacketTunnelProvider+Connectivity.swift
//  PIAWireguard
//  
//  Created by Jose Antonio Blaya Garcia on 26/02/2020.
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
import NetworkExtension
import os.log
import __PIAWireGuardNative

extension WGPacketTunnelProvider {
    
    func configureNetworkActivityListener() {
        
        DispatchQueue.main.async {
            if self.connectivityTimer == nil {
                self.connectivityTimer = Timer.scheduledTimer(timeInterval: self.connectivityInterval,
                                                             target: self,
                                                             selector: #selector(self.checkNetworkActivity),
                                                             userInfo: nil,
                                                             repeats: true)
                self.connectivityTimer?.tolerance = 5
            }
        }

    }
    
    @objc private func checkNetworkActivity() {
 
        let currentRxBytes = self.latestWireGuardSettings.rx_bytes
        
        self.updateSettings()
        
        if currentRxBytes == self.latestWireGuardSettings.rx_bytes {
            if wireGuardConnectionAttempts < wireGuardMaxConnectionAttempts {
                wg_log(.info, message: "Bytes not updated, retrying in 10 seconds")
                wireGuardConnectionAttempts += 1
            } else {
                wg_log(.info, message: "Max number of attempts to check if the tunnel is alive reached. We start to send pings now")
                wireGuardConnectionAttempts = 0
                self.connectivityTimer?.invalidate()
                self.connectivityTimer = Timer.scheduledTimer(timeInterval: 10,
                                                                target: self,
                                                                selector: #selector(self.checkPingActivity),
                                                                userInfo: nil,
                                                                repeats: true)
                checkIsConnectedToNetwork()
            }
        } else {
            wg_log(.info, message: "Bytes updated, retrying in 10 seconds")
            wireGuardConnectionAttempts = 0
        }
        
    }
    
    @objc private func checkPingActivity() {

        let currentRxBytes = self.latestWireGuardSettings.rx_bytes
        let currentTxBytes = self.latestWireGuardSettings.tx_bytes
        
        self.updateSettings()
        
        if currentRxBytes == self.latestWireGuardSettings.rx_bytes &&
        currentTxBytes == self.latestWireGuardSettings.tx_bytes {
            if wireGuardConnectionAttempts < wireGuardMaxConnectionAttempts {
                wg_log(.info, message: "Sending pings every 2 seconds and bytes not updated, retrying in 10 seconds")
                wireGuardConnectionAttempts += 1
            } else {
                wg_log(.info, message: "Max number of attempts to check if the tunnel is alive reached. Stopping the tunnel now")
                wireGuardConnectionAttempts = 0
                cancelTunnelWithError(nil)
            }
        } else {
            wg_log(.info, message: "Bytes updated. We start to check the bytes as normal every 10 seconds")
            wireGuardConnectionAttempts = 0
            pinger?.stop()
            self.connectivityTimer?.invalidate()
            self.connectivityTimer = Timer.scheduledTimer(timeInterval: 10,
                                                            target: self,
                                                            selector: #selector(self.checkNetworkActivity),
                                                            userInfo: nil,
                                                            repeats: true)

        }

    }
    
    private func checkIsConnectedToNetwork() {
        
        pinger?.start()

    }
    
}

