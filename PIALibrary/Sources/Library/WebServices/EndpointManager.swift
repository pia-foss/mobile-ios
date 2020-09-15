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

public class EndpointManager {
    
    private let internalUrl = "https://10.0.0.1:443"
    private let proxy = "https://piaproxy.net/"

    public static let shared = EndpointManager()

    public func availableEndpoints() -> [String] {
    
        if Client.configuration.currentServerNetwork() == .gen4 {
            
            if Client.providers.vpnProvider.isVPNConnected {
                return [internalUrl,
                        Client.configuration.baseUrl,
                        proxy]
            }
            
            var availableEndpoints = [String]()
            var currentServers = Client.providers.serverProvider.currentServers.filter { $0.serverNetwork == .gen4 }
            currentServers = currentServers.sorted(by: { $0.pingTime ?? 1000 < $1.pingTime ?? 1000 })

            if currentServers.count > 2 {
                availableEndpoints.append(currentServers[0].hostname) //TODO replace meta
                availableEndpoints.append(currentServers[1].hostname) //TODO replace meta
            }
            
            availableEndpoints.append(Client.configuration.baseUrl)
            availableEndpoints.append(proxy)
            
            return availableEndpoints

        } else {
            return [Client.configuration.baseUrl,
                    proxy]
        }
    }
    
}
