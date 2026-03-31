//
//  WGPacketTunnelProvider+Configuration.swift
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

    func uapiConfiguration(serverResponse: WGServerResponse) -> String {
        
        wg_log(.info, staticMessage: "uapiConfiguration:")

        var wgSettings = ""
        if let privateKey = self.wgPrivateKey.hexKey() {
            wgSettings.append("private_key=\(privateKey)\n")
        }
        
        //wgSettings.append("listen_port=\(serverResponse.server_port)\n")
        
        if !serverResponse.peer_ip.isEmpty {
            wgSettings.append("replace_peers=true\n")
        }
        
        if let publicKey = Data(base64Key: serverResponse.server_key)?.hexKey() {
            wgSettings.append("public_key=\(publicKey)\n")
            wg_log(.info, message: "public_key: \(publicKey)")
        } else {
            
        }
        
        let endPointString = "\(serverIPAddress):\(serverResponse.server_port)"
        wgSettings.append("endpoint=\(endPointString)\n")
        
        wgSettings.append("persistent_keepalive_interval=\(PIAWireguardConstants.persistentKeepaliveInterval)\n")
        
        wgSettings.append("replace_allowed_ips=true\n")
        wgSettings.append("allowed_ip=\(allowedIPRange)\n")
        
        wg_log(.info, message: "endpoint: \(endPointString)")
        wg_log(.info, message: "allowed_ip: \(allowedIPRange)")

        return wgSettings
    }
    
    func generateNetworkSettings(withDnsServer dnsServer: [String],
                                 packetSize mtu: Int,
                                 andServerResponse serverResponse: WGServerResponse) -> NEPacketTunnelNetworkSettings {
        
        /* iOS requires a tunnel endpoint, whereas in WireGuard it's valid for
         * a tunnel to have no endpoint, or for there to be many endpoints, in
         * which case, displaying a single one in settings doesn't really
         * make sense. So, we fill it in with this placeholder, which is not
         * a valid IP address that will actually route over the Internet.
         */
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: PIAWireguardConstants.tunnelRemoteAddress)
        
        let dns = dnsServer.isEmpty ? serverResponse.dns_servers : dnsServer
        let dnsSettings = NEDNSSettings(servers: dns)
        dnsSettings.matchDomains = [""] // All DNS queries must first go through the tunnel's DNS
        networkSettings.dnsSettings = dnsSettings
        networkSettings.mtu = NSNumber(value: mtu)

        let ipv4Settings = NEIPv4Settings(addresses: [serverResponse.peer_ip.ipAddress()], subnetMasks: [serverResponse.peer_ip.subnetMask()])
        let ipv4IncludedRoutes = [NEIPv4Route(destinationAddress: allowedIPRange.ipAddress(), subnetMask: allowedIPRange.subnetMask())]
        ipv4Settings.includedRoutes = ipv4IncludedRoutes
        networkSettings.ipv4Settings = ipv4Settings
        return networkSettings
    }
    
}
