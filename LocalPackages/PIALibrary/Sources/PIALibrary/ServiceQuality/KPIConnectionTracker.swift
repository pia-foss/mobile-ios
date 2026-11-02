//
//  KPIConnectionTracker.swift
//  PIALibrary
//
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

import NetworkExtension

enum KPIConnectionEvent: String {
    case vpnConnectionAttempt = "VPN_CONNECTION_ATTEMPT"
    case vpnConnectionCancelled = "VPN_CONNECTION_CANCELLED"
    case vpnConnectionEstablished = "VPN_CONNECTION_ESTABLISHED"
}

enum KPIConnectionStatus: Equatable {
    case notConnected
    case connecting
    case reconnecting
    case connected
    case paused

    // The tunnel's status is the PlatformSDK's own, the same one Android reports from, but it is
    // only live while the system reports the Network Extension as connected.
    init(system: NEVPNStatus, tunnel: PIATunnelSharedState.TunnelStatus?) {
        switch system {
        case .connected:
            switch tunnel {
            case .connected, nil: self = .connected
            case .connecting: self = .connecting
            case .reconnecting: self = .reconnecting
            case .paused: self = .paused
            case .disconnecting, .disconnected: self = .notConnected
            }
        case .connecting:
            self = .connecting
        case .reasserting:
            self = .reconnecting
        case .disconnecting, .disconnected, .invalid:
            self = .notConnected
        @unknown default:
            self = .notConnected
        }
    }
}

// Mirrors Android's SubmitKpiEventUseCase so both platforms report the same funnel.
struct KPIConnectionTracker {
    private(set) var status: KPIConnectionStatus?

    init(status: KPIConnectionStatus? = nil) {
        self.status = status
    }

    mutating func update(to newStatus: KPIConnectionStatus) -> KPIConnectionEvent? {
        let previousStatus = status
        guard newStatus != previousStatus else {
            return nil
        }
        status = newStatus

        switch newStatus {
        case .connecting, .reconnecting:
            return .vpnConnectionAttempt
        case .connected:
            // Unlike Android, only an attempt can be established: a resumed pause or a tunnel
            // adopted on launch was never reported as attempted.
            return previousStatus == .connecting || previousStatus == .reconnecting ? .vpnConnectionEstablished : nil
        case .notConnected:
            return previousStatus == .connecting ? .vpnConnectionCancelled : nil
        case .paused:
            return nil
        }
    }
}
