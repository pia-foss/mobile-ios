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

import Combine
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
    private var startTask: Task<Void, Never>?
    private let logger = PIATunnelLogger(label: "PIAPacketTunnelProvider")

    /// Mirrors the SDK's actual connected endpoint into `PIATunnelSharedState` for the app to read.
    private var connectedEndpointObservation: AnyCancellable?

    /// Serial queue the connected-endpoint write-back runs on, so its shared-state file I/O never
    /// blocks the extension's main thread and endpoint updates are applied in order.
    private let writeBackQueue = DispatchQueue(label: "com.privateinternetaccess.tunnel.activeConnectionWriteBack")

    // MARK: - Lifecycle

    open override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        startTask = Task {
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

        await observeConnectedEndpoint()

        try await sessionController?.start()
    }

    open override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        startTask?.cancel()
        Task {
            await startTask?.value
            startTask = nil

            await sessionController?.stop()
            sessionController = nil

            await MainActor.run {
                connectedEndpointObservation?.cancel()
                connectedEndpointObservation = nil
            }

            PIATunnelSharedState.clearActiveConnection()

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

    // MARK: - Active Connection Write-Back

    /// Mirrors the tunnel's *actual* connected endpoint into `PIATunnelSharedState` so the app can
    /// display the resolved protocol/server (vs. the user's possibly-Automatic selection). Only the
    /// protocol and the resolved region id are persisted — never the endpoint IP.
    @MainActor
    private func observeConnectedEndpoint() {
        connectedEndpointObservation = PacketTunnelState
            .shared
            .$connectedEndpoint
            .removeDuplicates()
            .receive(on: writeBackQueue)
            .sink(receiveValue: writeBackActiveConnection(for:))
    }

    private func writeBackActiveConnection(for endpoint: PacketTunnelConnectedEndpoint?) {
        guard let endpoint else {
            PIATunnelSharedState.clearActiveConnection()
            return
        }

        let tunnelProtocol = Self.piaTunnelProtocol(from: endpoint.protocolDescription)
        let serverId = Self.serverId(forConnectedHost: endpoint.host)

        guard let tunnelProtocol, let serverId else {
            PIATunnelSharedState.clearActiveConnection()
            return
        }

        let transport = Self.resolvedTransport(forProtocol: tunnelProtocol, description: endpoint.protocolDescription)

        PIATunnelSharedState.updateActiveConnection(
            protocol: tunnelProtocol,
            serverId: serverId,
            resolvedTransport: transport
        )
    }

    /// Resolves a connected endpoint host (IP) to the `Server.identifier` it belongs to, by scanning
    /// the current shared-state servers for the one that advertises this endpoint IP. The tunnel's
    /// endpoints are built from these same address lists (see `PIAEndpointRepository`), so a connected
    /// host always belongs to one of them; `nil` if no server matches (e.g. the list changed since
    /// connecting). The Dedicated IP target is carried separately in `selectedDipServer` (it is
    /// per-user and absent from the public `servers` list), so it must be included explicitly or DIP
    /// connections would never resolve. Called once per connect, so the linear scan is cheap.
    private static func serverId(forConnectedHost host: String) -> String? {
        let state = PIATunnelSharedState.read()
        let candidates = state.servers + [state.selectedDipServer].compactMap { $0 }
        return candidates.first { server in
            (server.openVPNAddressesForUDP ?? []).contains { $0.ip == host }
                || (server.openVPNAddressesForTCP ?? []).contains { $0.ip == host }
                || (server.wireGuardAddressesForUDP ?? []).contains { $0.ip == host }
        }?.identifier
    }

    /// Maps the SDK's `PacketTunnelConnectedEndpoint.protocolDescription` to the PIA shared-state
    /// protocol. The SDK has no structured protocol on the in-tunnel snapshot, so we match on the
    /// description it produces ("WireGuard"/"WireGuard+Amnezia", "openvpn-udp"/"openvpn-tcp").
    /// Returns `nil` for protocols PIA does not surface (e.g. Lightway). PIA wires only WG + OpenVPN.
    private static func piaTunnelProtocol(
        from protocolDescription: String
    ) -> PIATunnelSharedState.TunnelProtocol? {
        let description = protocolDescription.lowercased()
        if description.contains("wireguard") { return .wireGuard }
        if description.contains("openvpn") { return .openVPN }
        return nil
    }

    /// The concrete transport carrying the tunnel. WireGuard is always UDP; OpenVPN is parsed from
    /// the SDK's `protocolDescription` ("openvpn-udp"/"openvpn-tcp"), defaulting to `.udp` (OpenVPN's
    /// primary transport) if the description is unexpectedly unqualified. Always concrete.
    private static func resolvedTransport(
        forProtocol tunnelProtocol: PIATunnelSharedState.TunnelProtocol,
        description protocolDescription: String
    ) -> PIATunnelSharedState.VPNTransport {
        guard tunnelProtocol == .openVPN else { return .udp }
        return protocolDescription.lowercased().contains("tcp") ? .tcp : .udp
    }
}
