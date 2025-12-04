//
//  WifiNetworkMonitor.swift
//  PIA VPN
//
//  Created by Said Rehouni on 11/8/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Network
import NetworkExtension

class WifiNetworkMonitor: NetworkMonitor {
    
    private func getWifiAndEthernetIpAddress() -> [IPv4Address] {
        var addresses = [IPv4Address]()
        // Get list of all interfaces
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        defer {
            freeifaddrs(ifaddr)
        }
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return []
        }

        // Loop every interface, retrieve IPAddress and interface name (en0, en1, tun1)
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            // Find all active ifaddrs and avoid loopback interface.
            if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                let addr = ptr.pointee.ifa_addr.pointee
                if addr.sa_family == UInt8(AF_INET) {
                    // Convert interface address to a human readable string:
                    var ipAddressStr = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let nameInfo = getnameinfo(
                        ptr.pointee.ifa_addr,
                        socklen_t(addr.sa_len),
                        &ipAddressStr,
                        socklen_t(ipAddressStr.count),
                        nil,
                        socklen_t(0),
                        NI_NUMERICHOST
                    )
                    if nameInfo == 0,
                       let ipAddress = IPv4Address(.init(cString: ipAddressStr))
                    {
                        let interfaceName = String(cString: ptr.pointee.ifa_name)
                        if ipAddress.isLinkLocal == false && interfaceName.starts(with: "en") {
                            addresses.append(ipAddress)
                        }
                    }
                }
            }
        }
        return addresses
    }
    
    func checkForRFC1918Vulnerability() -> Bool {
        let wifiIPAddresses = getWifiAndEthernetIpAddress()
        return wifiIPAddresses.contains(where: { $0.isRFC1918Compliant == false })
    }
    
    func isConnected() -> Bool {
        if let currentNetworks = NEHotspotHelper.supportedNetworkInterfaces() {
            return currentNetworks.contains(where: { $0 is NEHotspotNetwork })
        }
        return false
    }
}
