//
//  PacketTunnelProvider.swift
//  PlatformSDK-Tunnel
//
//  Created by Diego Trevisan on 09.06.26.
//  Copyright © 2026 Private Internet Access, Inc.
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

import KapeVPN_PacketTunnel
import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    var sessionController: KapeSessionController?

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let wireguardAuthenticator = PIAWireguardAuthenticator()
        let endpointRepository = PIAEndpointRepository()
        let tunnel = KapeSystemTunnel(
            packetTunnelProvider: self,
            packetIOMode: .utunFd
        )

        let controller = KapeWireGuardController(
            systemTunnel: tunnel,
            authenticator: wireguardAuthenticator,
            logger: PIATunnelLogger(label: "KapeWireGuardController")
        )

        Task {
            sessionController = await SessionControllerFactory.make(
                configurationGenerator: endpointRepository,
                connectionControllers: [controller],
                appGroupIdentifier: "group.com.privateinternetaccess"
            ) { label in
                PIATunnelLogger(label: label)
            }

            try await sessionController?.start()
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        Task {
            await sessionController?.stop()
            sessionController = nil
            completionHandler()
        }
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        // Add code here to wake up.
    }
}
