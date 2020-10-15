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

public class EndpointManager {
    
    private let internalUrl = "10.0.0.1"
    private let proxy = "piaproxy.net"
    private let pia = "www.privateinternetaccess.com"
    private let region = "serverlist.piaservers.net"

    public static let shared = EndpointManager()

    private func availableMetaEndpoints(_ availableEndpoints: inout [PinningEndpoint]) {
        var currentServers = Client.providers.serverProvider.currentServers
        currentServers = currentServers.sorted(by: { $0.pingTime ?? 1000 < $1.pingTime ?? 1000 })
        currentServers = currentServers.filter({$0.meta != nil})

        if let historicalServer = Client.providers.serverProvider.historicalServers.first(where: {$0.meta != nil}) {
            availableEndpoints.append(PinningEndpoint(host: historicalServer.meta!.ip,
                                                      useCertificatePinning: true,
                                                      commonName: historicalServer.meta?.cn))
        }

        if currentServers.count > 2 {
            if currentServers[0].pingTime == nil && currentServers[1].pingTime == nil {
                while availableEndpoints.count < 2 {
                    availableEndpoints.append(PinningEndpoint(host: currentServers.randomElement()!.meta!.ip, useCertificatePinning: true, commonName: currentServers.randomElement()?.meta?.cn))
                }
            } else {
                availableEndpoints.append(PinningEndpoint(host: currentServers[0].meta!.ip, useCertificatePinning: true, commonName: currentServers[0].meta?.cn))
                if availableEndpoints.count < 2 {
                    availableEndpoints.append(PinningEndpoint(host: currentServers[1].meta!.ip, useCertificatePinning: true, commonName: currentServers[1].meta?.cn))
                }
            }
        }
        
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
        availableMetaEndpoints(&availableEndpoints)

        availableEndpoints.append(PinningEndpoint(host: pia))
        availableEndpoints.append(PinningEndpoint(host: proxy, isProxy: true))
        
        return availableEndpoints
    }
    
}
