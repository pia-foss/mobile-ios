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

    /// Mirrors the SDK's live tunnel status into `PIATunnelSharedState` so the app can fold it into
    /// its VPN status (an in-place switch / reconnect keeps `NEVPNStatus` at `.connected`).
    private var tunnelStatusObservation: AnyCancellable?

    /// Serial queue the write-backs run on, so their shared-state file I/O never blocks the
    /// extension's main thread and updates are applied in order.
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
        // Clear any status that might have been left by a previous tunnel
        PIATunnelSharedState.clearStatus()

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
        await observeTunnelStatus()

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
                tunnelStatusObservation?.cancel()
                tunnelStatusObservation = nil
            }

            PIATunnelSharedState.clearActiveConnection()
            PIATunnelSharedState.clearTunnelStatus()

            completionHandler()
        }
    }

    open override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        guard let request = try? JSONDecoder().decode(PIAPacketTunnelRequest.self, from: messageData) else {
            completionHandler?(nil)
            return
        }

        switch request {
        case .switchLocation:
            logger.info("switchLocation requested")
            Task {
                do {
                    try await sessionController?.switchLocation()
                } catch {
                    logger.error("switchLocation failed: \(error)")
                }
                completionHandler?(nil)
            }

        case .dataUsage:
            logger.info("dataUsage requested")
            Task {
                if let usage = await sessionController?.currentDataUsage() {
                    completionHandler?(try? JSONEncoder().encode(usage))
                } else {
                    completionHandler?(nil)
                }
            }

        case .requestLog:
            logger.info("requestLog requested")
            completionHandler?(PIATunnelLogStore.shared.snapshot().data(using: .utf8))
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

    /// Mirrors the SDK's live tunnel status into `PIATunnelSharedState`. The app folds this into its
    /// VPN status so a mid-session reconnect or an in-place region switch — both of which keep
    /// `NEVPNStatus` at `.connected` — still surface as "Connecting".
    @MainActor
    private func observeTunnelStatus() {
        tunnelStatusObservation = PacketTunnelState
            .shared
            .$tunnelStatus
            .removeDuplicates()
            .receive(on: writeBackQueue)
            .sink(receiveValue: writeBackTunnelStatus(for:))
    }

    private func writeBackTunnelStatus(for status: KapeVPNConnectionStatus?) {
        guard let status else {
            PIATunnelSharedState.clearTunnelStatus()
            return
        }
        PIATunnelSharedState.updateTunnelStatus(Self.piaTunnelStatus(from: status))
    }

    /// Maps the SDK's `KapeVPNConnectionStatus` to PIA's shared-state `TunnelStatus` (a 1:1 mapping;
    /// PIA-owned so PIALibrary carries no Kape dependency).
    private static func piaTunnelStatus(from status: KapeVPNConnectionStatus) -> PIATunnelSharedState.TunnelStatus {
        switch status {
        case .connected: return .connected
        case .connecting: return .connecting
        case .reconnecting: return .reconnecting
        case .disconnecting: return .disconnecting
        case .disconnected: return .disconnected
        case .paused: return .paused
        }
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

    /// Resolves a connected endpoint host (IP) to the `Server.identifier` it belongs to.
    ///
    /// A host is not a unique key: sibling regions share physical servers — DE Frankfurt and DE Germany
    /// Streaming Optimized advertise two of the same three WireGuard addresses — so a scan returns
    /// whichever the name-sorted list carries first, relabelling a selection as its sibling. Hence
    /// `selectedLocationId` wins when it advertises the host; only "Automatic" falls back to the scan.
    /// DIP is included explicitly (`selectedDipServer` is per-user, absent from `servers`). `nil` when
    /// nothing matches, e.g. the list changed since connecting.
    private static func serverId(forConnectedHost host: String) -> String? {
        let state = PIATunnelSharedState.read()
        let candidates = state.servers + [state.selectedDipServer].compactMap { $0 }

        if let selectedLocationId = state.selectedLocationId,
            let target = candidates.first(where: { $0.identifier == selectedLocationId && $0.dipToken == nil }),
            advertises(target, host: host)
        {
            return target.identifier
        }

        return candidates.first { advertises($0, host: host) }?.identifier
    }

    /// Whether `server` lists `host` among the addresses `PIAEndpointRepository` builds endpoints from.
    private static func advertises(_ server: Server, host: String) -> Bool {
        let openVPNAddressesForUDP = server.openVPNAddressesForUDP ?? []
        let openVPNAddressesForTCP = server.openVPNAddressesForTCP ?? []
        let wireGuardAddressesForUDP = server.wireGuardAddressesForUDP ?? []

        return (openVPNAddressesForUDP + openVPNAddressesForTCP + wireGuardAddressesForUDP).contains { $0.ip == host }
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
