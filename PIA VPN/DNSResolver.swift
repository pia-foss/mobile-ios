//
//  DNSResolver.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/15/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

class DNSResolver {
    private let hostname: String
    
    init(hostname: String) {
        self.hostname = hostname
    }

    func resolve(completionHandler: ([String]?, Error?) -> Void) {
        let host = CFHostCreateWithName(nil, hostname as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)

        var success: DarwinBoolean = false
        guard let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? else {
            completionHandler(nil, nil)
            return
        }
        var ipAddresses: [String] = []
        for case let theAddress as NSData in addresses {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                continue
            }
            ipAddresses.append(String(cString: hostname))
        }
        completionHandler(ipAddresses, nil)
    }

    static func string(fromIPv4 ipv4: UInt32) -> String {
        let a = UInt8(ipv4) & 0xff
        let b = UInt8(ipv4 >> 8) & 0xff
        let c = UInt8(ipv4 >> 16) & 0xff
        let d = UInt8(ipv4 >> 24) & 0xff

        return "\(a).\(b).\(c).\(d)"
    }
}
