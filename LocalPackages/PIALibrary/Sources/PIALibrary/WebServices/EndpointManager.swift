//
//  EndpointManager.swift
//  PIALibrary
//
//  Created by Jose Blaya on 15/09/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation

@available(tvOS 17.0, *)
public struct PinningEndpoint {
    let host: String
    let isProxy: Bool
    let useCertificatePinning: Bool
    let commonName: String?
    
    init(host: String, isProxy: Bool = false, useCertificatePinning: Bool = false, commonName: String? = nil) {
        self.host = host
        self.isProxy = isProxy
        self.useCertificatePinning = useCertificatePinning
        self.commonName = commonName
    }
}

@available(tvOS 17.0, *)
public class EndpointManager {
    
    private let internalUrl = "10.0.0.1"
    private let proxy = "piaproxy.net"
    private let pia = "privateinternetaccess.com"
    private let region = "serverlist.piaservers.net"
    private let csi = "csi.supreme.tools"

    public static let shared = EndpointManager()

    private func availableMetaEndpoints(_ availableEndpoints: inout [PinningEndpoint]) {
        var currentServers = Client.providers.serverProvider.currentServers
        currentServers = currentServers.sorted(by: { $0.pingTime ?? 1000 < $1.pingTime ?? 1000 })
        
        if let historicalServer = Client.providers.serverProvider.historicalServers.first,
           let meta = historicalServer.meta {
            availableEndpoints.append(PinningEndpoint(host: meta.ip,
                                                      isProxy: true,
                                                      useCertificatePinning: true,
                                                      commonName: meta.cn))
        }

        if currentServers.count > 2 {
            let filtered = currentServers.filter({$0.pingTime != nil}).sorted(by: { $0.pingTime ?? 0 < $1.pingTime ?? 0 })
            
            guard !currentServers.filter({$0.meta != nil}).isEmpty else {
                return
            }
            if filtered.count < 2 {
                while availableEndpoints.count < 2 {
                    if let random = currentServers.randomElement(), let meta = random.meta {
                        availableEndpoints.append(PinningEndpoint(host: meta.ip, isProxy: true, useCertificatePinning: true, commonName: meta.cn))
                    }
                }
            } else {
                if let meta = filtered.first?.meta {
                    availableEndpoints.append(PinningEndpoint(host: meta.ip ,isProxy: true, useCertificatePinning: true, commonName: meta.cn))
                }
                if availableEndpoints.count < 2 {
                    if let meta = filtered[1].meta {
                        availableEndpoints.append(PinningEndpoint(host: meta.ip, isProxy: true, useCertificatePinning: true, commonName: meta.cn))
                    }
                }
            }
        }
        
    }
    
    public func availableCSIEndpoints() -> [PinningEndpoint] {
        return [PinningEndpoint(host: csi)]
    }
    
    public func availableRegionEndpoints() -> [PinningEndpoint] {
        if Client.providers.vpnProvider.isVPNConnected {
            return [PinningEndpoint(host: internalUrl),
                    PinningEndpoint(host: region)]
        }
        
        var availableEndpoints = [PinningEndpoint]()
        availableMetaEndpoints(&availableEndpoints)
        
        availableEndpoints.append(PinningEndpoint(host: region))
        
        return availableEndpoints
    }
    
    public func availableEndpoints() -> [PinningEndpoint] {
        if Client.providers.vpnProvider.isVPNConnected {
            return [PinningEndpoint(host: internalUrl),
                    PinningEndpoint(host: pia),
                    PinningEndpoint(host: proxy, isProxy: true)]
        }
        
        var availableEndpoints = [PinningEndpoint]()
        availableEndpoints.append(PinningEndpoint(host: pia))
        availableEndpoints.append(PinningEndpoint(host: proxy, isProxy: true))
        availableMetaEndpoints(&availableEndpoints)
        
        return availableEndpoints
    }
    
}
