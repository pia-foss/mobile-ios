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

import KapeVPN_OpenVPN
import KapeVPN_PacketTunnel
import NetworkExtension
import PIALibrary

/// Base PacketTunnelProvider for PIA's PlatformSDK tunnel. The extension target subclasses this
/// (`class PacketTunnelProvider: PIAPacketTunnelProvider {}`), mirroring the Kape SDK's
/// `KapePacketTunnelProvider`. All wiring lives here so the extension stays a thin shell.
///
/// `@unchecked Sendable`: `NEPacketTunnelProvider` lifecycle callbacks are delivered on arbitrary
/// threads, so actor isolation would fight the framework (same rationale as `KapePacketTunnelProvider`).
open class PIAPacketTunnelProvider: NEPacketTunnelProvider, @unchecked Sendable {

    var sessionController: KapeSessionController?
    private let logger = PIATunnelLogger(label: "PIAPacketTunnelProvider")

    open override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        Task {
            do {
                try await start()
                completionHandler(nil)
            } catch {
                logger.error("Failed to start tunnel: \(error)")
                completionHandler(error)
            }
        }
    }

    private func start() async throws {
        let endpointRepository = PIAEndpointRepository()
        let systemTunnel = KapeSystemTunnel(packetTunnelProvider: self, packetIOMode: .utunFd)

        let wgController = KapeWireGuardController(
            systemTunnel: systemTunnel,
            authenticator: PIAWireguardAuthenticator(),
            logger: PIATunnelLogger(label: "KapeWireGuardController")
        )

        let openVPNController = OpenVPNConnectionController(
            systemTunnel: systemTunnel,
            logger: PIATunnelLogger(label: "OpenVPNConnectionController"),
            driverFactory: {
                TunnelKitOpenVPNDriver(logger: PIATunnelLogger(label: "TunnelKitOpenVPNDriver"))
            }
        )

        // Pass `systemTunnel` as the reasserting controller so the session controller can drive
        // the NE `reasserting` flag during mid-session reconnects (e.g. wifi↔cellular path
        // changes). `VPNDaemon` maps `.reasserting` to its connecting state, so without this the
        // app UI would keep showing "Connected" through the reconnect gap. `systemTunnel` also
        // doubles as the bypass sink the factory expects.
        sessionController = await SessionControllerFactory.make(
            configurationGenerator: endpointRepository,
            connectionControllers: [wgController, openVPNController],
            appGroupIdentifier: AppConstants.appGroup,
            loggerFactory: { label in PIATunnelLogger(label: label) },
            reassertingController: systemTunnel,
            systemTunnel: systemTunnel
        )

        try await sessionController?.start()
    }

    open override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        Task {
            await sessionController?.stop()
            sessionController = nil
            completionHandler()
        }
    }

    open override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    open override func sleep(completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    open override func wake() {}
}
