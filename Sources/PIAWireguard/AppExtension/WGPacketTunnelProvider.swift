// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import Network
import NetworkExtension
import os.log
import __PIAWireGuardNative

open class WGPacketTunnelProvider: NEPacketTunnelProvider {

    var handle: Int32?
    var networkMonitor: NWPathMonitor?
    var ifname: String?
    private var packetTunnelSettingsGenerator: PacketTunnelSettingsGenerator?
    private var logViewHelper: LogViewHelper?
    
    var wgPrivateKey: Data = Data()
    var wgPublicKey: Data = Data()
    let allowedIPRange = PIAWireguardConstants.allowedIPRange
    var serverIPAddress = ""

    var pinger: SwiftyPing!
    var connectivityTimer: Timer?
    var latestWireGuardSettings: WGSettingsResponse!
    let wireGuardMaxConnectionAttempts = 3
    let connectivityInterval: TimeInterval = 10
    let pingInterval: TimeInterval = 2
    var wireGuardConnectionAttempts = 0
    
    var providerConfiguration: [String: Any]!

    deinit {
        networkMonitor?.cancel()
    }
    
    override open func startTunnel(options: [String: NSObject]?, completionHandler startTunnelCompletionHandler: @escaping (Error?) -> Void) {

        guard let tunnelProtocol = protocolConfiguration as? NETunnelProviderProtocol else {
            let msg = "WGPacketTunnel: protocolConfiguration not found"
            wg_log(.info, staticMessage: "WGPacketTunnel: protocolConfiguration not found")
            self.stopTunnel(withMessage: msg)
            return
        }
        
        guard let providerConfiguration = tunnelProtocol.providerConfiguration else {
            let msg = "WGPacketTunnel: providerConfiguration not found"
            wg_log(.info, staticMessage: "WGPacketTunnel: providerConfiguration not found")
            self.stopTunnel(withMessage: msg)
            return
        }
        
        guard let serverAddress = tunnelProtocol.serverAddress else {
            let msg = "WGPacketTunnel: serverAddress not found"
            wg_log(.info, staticMessage: "WGPacketTunnel: serverAddress not found")
            self.stopTunnel(withMessage: msg)
            return
        }

        self.providerConfiguration = providerConfiguration
        
        //Remove the error file from the last connection
        ErrorNotifier.removeLastErrorFile()

        if let logFileURL = FileManager.logFileURL {
            self.logViewHelper = LogViewHelper(logFilePath: logFileURL.path)
        }
        
        let activationAttemptId = providerConfiguration["activationAttemptId"] as? String
        
        guard let useIP = self.providerConfiguration[PIAWireguardConfiguration.Keys.useIP] as? Bool else {
            let msg = "WGPacketTunnel: use IP key not found"
            wg_log(.info, staticMessage: "WGPacketTunnel: use IP key not found")
            self.stopTunnel(withMessage: msg)
            return
        }

        if useIP {
            addPublicKeyToServerIp(serverAddress: serverAddress,
                                   withCompletionHandler: startTunnelCompletionHandler)
        } else {
            addPublicKeyToServer(serverAddress: serverAddress,
                                 withCompletionHandler: startTunnelCompletionHandler)
        }
        
        configureLogger()
        #if os(macOS)
        wgEnableRoaming(true)
        #endif

        wg_log(.info, message: "Starting tunnel from the " + (activationAttemptId == nil ? "OS directly, rather than the app" : "app"))
    }
        
    func stopTunnel(withMessage msg: String) {
        wg_log(.info, message: msg)
        self.stopTunnel(with: .configurationFailed, completionHandler: {})
    }

    override open func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {

        networkMonitor?.cancel()
        networkMonitor = nil
        
        connectivityTimer?.invalidate()
        connectivityTimer = nil
        
        wg_log(.info, staticMessage: "Stopping tunnel")
             
        
        if let handle = handle {
            wgTurnOff(handle)
        }
        completionHandler()

    }

    override open func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
           
       guard let completionHandler = completionHandler else { return }
      
       switch Message(messageData) {
       case .requestLog:
            guard let logHelper = self.logViewHelper else {
                completionHandler(nil)
                return
            }
            
            logHelper.fetchLogEntriesSinceLastFetch { entries in
            
                let allStringEntries = entries.map { $0.text() }
                let singleLogString = allStringEntries.joined(separator: "\n")
                completionHandler(singleLogString.data(using: .utf8))

            }
        
       case .dataCount:
           
            self.updateSettings(completionHandler: nil)

            guard let settings = latestWireGuardSettings else {
                return
            }
            
            var response = Data()
            response.append(settings.rx_bytes) // inbound
            response.append(settings.tx_bytes) // outbound
            completionHandler(response)
           
       default:
           break
       }

   }

    private func configureLogger() {
        let context = Unmanaged.passUnretained(self).toOpaque()
    
        Logger.configureGlobal(tagged: "PIA", withFilePath: FileManager.logFileURL?.path)
        wgSetLogger(context) { context, level, message in
            guard let message = message else { return }
            let logType: OSLogType
            switch level {
            case 0:
                logType = .debug
            case 1:
                logType = .info
            case 2:
                logType = .error
            default:
                logType = .default
            }
            wg_log(logType, message: String(cString: message))
        }
    }

    func pathUpdate(path: Network.NWPath) {
        
        guard let handle = handle else { return }
        
        wg_log(.info, staticMessage: "Network change detected")
        wg_log(.debug, message: "Network change detected with \(path.status) route and interface order \(path.availableInterfaces)")

        #if os(iOS)
        if let packetTunnelSettingsGenerator = packetTunnelSettingsGenerator {
            _ = packetTunnelSettingsGenerator.endpointUapiConfiguration().withCString {
                return wgSetConfig(handle, $0 as? UnsafeMutablePointer<Int8>)
            }
        }
        #endif
        
        wgBumpSockets(handle)

        updateSettings()
        configureNetworkActivityListener()

    }
    
    func updateSettings(completionHandler: ((Data?) -> Void)? = nil) {
        
        guard let handle = handle else {
            completionHandler?(nil)
            return
            
        }

        guard let settings = wgGetConfig(handle) else {
            completionHandler?(nil)
            return
        }

        latestWireGuardSettings = WGSettingsResponse(withSettings: String(cString: settings))
        free(settings)
    }
    
}
