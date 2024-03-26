//
//  VPNServerStatusUseCase.swift
//  PIA VPN
//
//  Created by Laura S on 3/25/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Network

protocol VPNServerStatusUseCaseType {
    @available(iOS 13.0, *)
    func getServerStatus()
}


class VPNServerStatusUseCase: VPNServerStatusUseCaseType {
    private var connection: NWHttpConnectionType?
    
    init() {
        if #available(iOS 13.0, *) {
            self.connection = configureConnection()
        }
    }
    
    @available(iOS 13.0, *)
    func configureConnection() -> NWHttpConnectionType? {
        guard let url = APIRequest.vpnStatus.asURL else {
            return nil
        }
        
        // TODO: For connections from the WG Servers, we need to pass the cn from `WGPacketTunnelProvider`
        return NWHttpConnection(url: url, method: .get, certificateValidation: .anchorCert(cn: nil))
    }
    
    @available(iOS 13.0, *)
    func getServerStatus() {
        getServerStatusWithNWConnection()
        
    }
    
    
    @available(iOS 13.0, *)
    private func getServerStatusWithNWConnection() {
        guard let connection else { return }
        do {
            try connection.connect { error, data in
                NSLog(">>> >>> Connection error: \(error)")
                if let data {
                    let asciEncoding = String(data: data, encoding: String.Encoding.ascii)
                    let utf8Encoding = String(data: data, encoding: String.Encoding.utf8)
                    let utf16Encoding = String(data: data, encoding: String.Encoding.utf16)
                    NSLog(">>> >>> Parsed ascii Data: \(asciEncoding)")
                    
                }
                
                
            } completion: {
                
            }
        } catch {
            // TODO: Handle error
        }
    }
    
    
}

extension VPNServerStatusUseCase {
    enum APIRequest: String {
        // TODO: Add server IP here
        case vpnStatus = "https://xxxserverIP/api/client/status"

        var asURL: URL? {
            return URL(string: self.rawValue)
        }
    }
}



