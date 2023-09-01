//
//  WGPacketTunnelProvider+API.swift
//  PIAWireguard
//  
//  Created by Jose Antonio Blaya Garcia on 27/02/2020.
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
import Network
import NetworkExtension
import os.log
import __PIAWireGuardNative
import Alamofire
import TweetNacl
import NWHttpConnection

extension WGPacketTunnelProvider: URLSessionDelegate {
    
    func addPublicKeyToServer(serverAddress: String,
                              withCompletionHandler startTunnelCompletionHandler: @escaping (Error?) -> Void) {
        
        guard let piaToken = self.providerConfiguration[PIAWireguardConfiguration.Keys.token] as? String else {
            let msg = "WGPacketTunnel: pia auth token not found"
            self.stopTunnel(withMessage: msg)
            return
        }
                
        //Generate private key
        let keys = try! NaclBox.keyPair()
        wgPublicKey = keys.publicKey
        wgPrivateKey = keys.secretKey
        
        let baseUrl = WGClientEndpoint.addKey(serverAddress: serverAddress,
                                              port: PIAWireguardConstants.remotePort).url
        
        let params = [PIAWireguardConstants.API.publicKeyParameter: generateURLEncodedString(from: wgPublicKey),
                      PIAWireguardConstants.API.authTokenParameter: piaToken]
        
        var reqURLComponents = URLComponents(string: baseUrl.absoluteString)
        var reqQueryItems: [URLQueryItem] = []
        for param in params {
            let queryItem = URLQueryItem(name: param.key, value: param.value)
            reqQueryItems.append(queryItem)
        }
        reqURLComponents?.queryItems = reqQueryItems
        
        if let reqURL = reqURLComponents?.url,
           let cn = self.providerConfiguration[PIAWireguardConfiguration.Keys.cn] as? String {
            startNWConnection(for: reqURL, cn: cn, completionHandler: startTunnelCompletionHandler)
        }

    }
    
    func addPublicKeyToServerIp(serverAddress: String,
                              withCompletionHandler startTunnelCompletionHandler: @escaping (Error?) -> Void) {
        
        guard let piaToken = self.providerConfiguration[PIAWireguardConfiguration.Keys.token] as? String else {
            let msg = "WGPacketTunnel: pia auth token not found"
            self.stopTunnel(withMessage: msg)
            return
        }

        //Generate private key
        let keys = try! NaclBox.keyPair()
        wgPublicKey = keys.publicKey
        wgPrivateKey = keys.secretKey
        
        let reqURL = URL(string: "https://\(serverAddress):1337/addKey?pubkey=\(generateURLEncodedString(from: wgPublicKey))&pt=\(piaToken)")
        
        if let reqURL,
           let cn = self.providerConfiguration[PIAWireguardConfiguration.Keys.cn] as? String {

            startNWConnection(for: reqURL, cn: cn, completionHandler: startTunnelCompletionHandler)
        }
        

    }
    
    private var tunnelFileDescriptor: Int32? {
        var ctlInfo = ctl_info()
        withUnsafeMutablePointer(to: &ctlInfo.ctl_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0.pointee)) {
                _ = strcpy($0, "com.apple.net.utun_control")
            }
        }
        for fd: Int32 in 0...1024 {
            var addr = sockaddr_ctl()
            var ret: Int32 = -1
            var len = socklen_t(MemoryLayout.size(ofValue: addr))
            withUnsafeMutablePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    ret = getpeername(fd, $0, &len)
                }
            }
            if ret != 0 || addr.sc_family != AF_SYSTEM {
                continue
            }
            if ctlInfo.ctl_id == 0 {
                ret = ioctl(fd, CTLIOCGINFO, &ctlInfo)
                if ret != 0 {
                    continue
                }
            }
            if addr.sc_id == ctlInfo.ctl_id {
                return fd
            }
        }
        return nil
    }


    
    private func parse(_ data: Data,
                       withCompletionHandler startTunnelCompletionHandler: @escaping (Error?) -> Void) {
        
        guard let dnsServers = self.providerConfiguration[PIAWireguardConfiguration.Keys.dnsServers] as? [String] else {
            let msg = "WGPacketTunnel: dnsServer not found"
            wg_log(.info, staticMessage: "WGPacketTunnel: dnsServer not found")
            self.stopTunnel(withMessage: msg)
            return
        }
        guard let ping = self.providerConfiguration[PIAWireguardConfiguration.Keys.ping] as? String else {
            let msg = "WGPacketTunnel: ping server not found"
            wg_log(.info, staticMessage: "WGPacketTunnel: ping server not found")
            self.stopTunnel(withMessage: msg)
            return
        }
        
        let packetSize = self.providerConfiguration[PIAWireguardConfiguration.Keys.packetSize] as? Int ?? PIAWireguardConstants.mtu
        
        if let serverResponse = try? JSONDecoder().decode(WGServerResponse.self, from: data) {
            wg_log(.info, staticMessage: "WGPacketTunnel: NWConnection data was parsed successfully")
            
            self.serverIPAddress = serverResponse.server_ip
            guard !self.serverIPAddress.isEmpty else {
                let msg = "WGPacketTunnel: Remote address not found"
                wg_log(.info, staticMessage: "WGPacketTunnel: Remote address not found")
                self.stopTunnel(withMessage: msg)
                return
            }
            
            wg_log(.info, staticMessage: "Configuring network settings")
            
            self.setTunnelNetworkSettings(self.generateNetworkSettings(withDnsServer: dnsServers,
                                                                       packetSize: packetSize,
                                                                       andServerResponse: serverResponse)) { (error) in
                                                                        if let error = error {
                                                                            wg_log(.info, staticMessage: "WGPacketTunnel: could not set network settings")
                                                                            wg_log(.error, message: error.localizedDescription)
                                                                            self.stopTunnel(with: .configurationFailed, completionHandler: {})
                                                                        } else {
                                                                            
                                                                            self.networkMonitor = NWPathMonitor()
                                                                            self.networkMonitor!.pathUpdateHandler = self.pathUpdate
                                                                            self.networkMonitor!.start(queue: DispatchQueue(label: "NetworkMonitor"))
                                                                            
                                                                            
                                                                            let fileDescriptor = self.tunnelFileDescriptor ?? -1
                                                                            if fileDescriptor < 0 {
                                                                                let msg = "WGPacketTunnel: could not determine file descriptor"
                                                                                wg_log(.info, staticMessage: "WGPacketTunnel: could not determine file descriptor")
                                                                                self.stopTunnel(withMessage: msg)
                                                                                return
                                                                            }
                                                                            
                                                                            var ifnameSize = socklen_t(IFNAMSIZ)
                                                                            let ifnamePtr = UnsafeMutablePointer<CChar>.allocate(capacity: Int(ifnameSize))
                                                                            ifnamePtr.initialize(repeating: 0, count: Int(ifnameSize))
                                                                            if getsockopt(fileDescriptor, 2 /* SYSPROTO_CONTROL */, 2 /* UTUN_OPT_IFNAME */, ifnamePtr, &ifnameSize) == 0 {
                                                                                self.ifname = String(cString: ifnamePtr)
                                                                            }
                                                                            ifnamePtr.deallocate()
                                                                            wg_log(.info, message: "Tunnel interface is \(self.ifname ?? "unknown")")
                                                                            
                                                                            self.pinger = SwiftyPing(host: ping, configuration: PingConfiguration(interval: self.pingInterval, with: 5), queue: DispatchQueue.global())
                                                                            
                                                                            let wgConfig = self.uapiConfiguration(serverResponse: serverResponse)
                                                                            let handle = wgTurnOn(wgConfig, fileDescriptor)
                                                                    
                                                                            if handle < 0 {
                                                                                wg_log(.info, staticMessage: "WGPacketTunnel: could not start backend")
                                                                                startTunnelCompletionHandler(PacketTunnelProviderError.couldNotStartBackend)
                                                                                return
                                                                            }
                                                                            
                                                                            self.handle = handle
                                                                            self.updateSettings()
                                                                            self.configureNetworkActivityListener()
                                                                            wg_log(.info, staticMessage: "WGPacketTunnel: will start the tunnel")
                                                                            startTunnelCompletionHandler(nil)
                                                                            
                                                                        }
            }
            
        } else {
            let msg = "WGPacketTunnel: unable to parse data: \(String(data: data, encoding: .utf8) ?? data.description) ourKey: \(self.wgPublicKey.base64EncodedString())"
            wg_log(.info, staticMessage: "WGPacketTunnel: unable to parse NWConnection data")
            wg_log(.debug, message: msg)
            self.stopTunnel(withMessage: msg)
        }
    }

}

extension WGPacketTunnelProvider {
    func startNWConnection(for url: URL, cn: String, completionHandler: @escaping (Error?) -> Void) {
        wg_log(.info, staticMessage: "Will start NWConnection to add public key")
        
        guard let anchorCert = getAnchorCertificate() else {
            wg_log(.error, staticMessage: "Could not find anchor certificate to start NWConnection")
            return
        }
        
        let configuration = NWConnectionConfiguration(url: url, method: .get, body: nil, certificateValidation: .anchor(certificate: anchorCert, commonName: cn), dataResponseType: .jsonData)
        let connection = NWHttpConnectionFactory.makeNWHttpConnection(with: configuration)
        
        do {
            try connection.connect { error, data in
                if let error {
                    wg_log(.info, staticMessage: "NWConnection did receive error")
                    wg_log(.info, message: error.localizedDescription)
                    wg_log(.error, message: error.localizedDescription)
                } else if let responseData = data?.data as? Data {
                    wg_log(.info, staticMessage: "NWConnection did receive data")
                    self.parse(responseData, withCompletionHandler: completionHandler)
                } else {
                    wg_log(.info, staticMessage: "NWConnection did NOT receive error and Data")
                }
                    
            } completion: {
               // No op
                wg_log(.info, staticMessage: "NWConnection did complete")
            }

        } catch {
            wg_log(.error, message: error.localizedDescription)
            wg_log(.info, staticMessage: "NWConnection error thrown at start")
            stopTunnel(withMessage: error.localizedDescription)
        }
    }
}


private extension WGPacketTunnelProvider {

    func generateURLEncodedString(from data: Data) -> String {
        var wgKeyString = data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!
        
        if wgKeyString.contains("+") {
            wgKeyString = wgKeyString.replacingOccurrences(of: "+", with: "%2B")
        }
        
        let logString = String(format: "Generated wg pub key: %@", wgKeyString)
        wg_log(.info, message: logString)
        return wgKeyString
    }
    
    func getAnchorCertificate() -> SecCertificate? {
        
#if SWIFT_PACKAGE
            let bundle = Bundle.module
#else
            let bundle = Bundle(for: WGPacketTunnelProvider.self)
#endif
        
       guard let certURL = bundle.url(forResource: "PIA", withExtension: "der"),
             let certificateData = try? Data(contentsOf: certURL) as CFData else {
           wg_log(.info, staticMessage: "WGPacketTunnelProvider: could no find or encode contents of anchor cert")
           return nil
       }
        
        let caRef = SecCertificateCreateWithData(nil, certificateData)
        
        if caRef == nil {
            wg_log(.info, staticMessage: "WGPacketTunnel: anchorCert, could not generate SecCertificate")
        } else {
            wg_log(.info, staticMessage: "WGPacketTunnel: SecCertificate generated successfully")
        }
        
        return caRef
    }
}
