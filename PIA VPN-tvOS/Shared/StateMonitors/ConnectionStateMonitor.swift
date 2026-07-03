//
//  ConnectionStatusMonitor.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Combine
import Foundation
import PIADashboard
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: ConnectionStateMonitor.self)

enum ConnectionState: Equatable {
    case unkown
    case disconnected
    case connecting
    case connected
    case disconnecting
    case error(Error)

    static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.unkown, .unkown):
            return true
        case (.disconnected, .disconnected):
            return true
        case (.connecting, .connecting):
            return true
        case (.connected, .connected):
            return true
        case (.disconnecting, .disconnecting):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }

    var title: String? {
        switch self {
        case .connected:
            return L10n.Dashboard.ConnectionState.Connected.title
        case .disconnected:
            return L10n.Dashboard.ConnectionState.Disconnected.title
        case .disconnecting:
            return L10n.Dashboard.ConnectionState.Disconnecting.title
        case .connecting:
            return L10n.Dashboard.ConnectionState.Connecting.title
        case .error(_):
            return L10n.Dashboard.ConnectionState.Error.title
        default:
            return nil
        }
    }
}

protocol ConnectionStateMonitorType {
    var currentConnectionState: ConnectionState { get }
    var connectionStatePublisher: Published<ConnectionState>.Publisher { get }
    func callAsFunction()
}

final class ConnectionStateMonitor: ConnectionStateMonitorType {
    private var cancellable: AnyCancellable?

    private let vpnStatusMonitor: VPNStatusMonitorType
    private let vpnConnectionUseCase: VpnConnectionUseCaseType

    @Published private var connectionState: ConnectionState = .unkown
    var connectionStatePublisher: Published<ConnectionState>.Publisher {
        $connectionState
    }
    var currentConnectionState: ConnectionState { connectionState }

    init(vpnStatusMonitor: VPNStatusMonitorType, vpnConnectionUseCase: VpnConnectionUseCaseType) {
        self.vpnStatusMonitor = vpnStatusMonitor
        self.vpnConnectionUseCase = vpnConnectionUseCase
    }

    func callAsFunction() {
        cancellable = Publishers.CombineLatest(
            vpnStatusMonitor.getStatus(),
            vpnConnectionUseCase.getConnectionIntent()
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] vpnStatus, connectionIntent in
            self?.calculateState(for: connectionIntent, vpnStatus: vpnStatus)
        }
    }

    private func calculateState(for connectionIntent: VpnConnectionIntent, vpnStatus: VPNStatus) {
        let previousState = connectionState

        switch (connectionIntent, vpnStatus) {
        case (.disconnect, _):
            self.connectionState = .disconnecting
        case (_, .connected):
            self.connectionState = .connected
        case (.connect, _):
            self.connectionState = .connecting
        case (_, .disconnected):
            self.connectionState = .disconnected
        default:
            self.connectionState = vpnStatus.toConnectionState()
        }

        if previousState != connectionState {
            log.debug("ConnectionState: \(previousState) → \(connectionState) [intent: \(connectionIntent), vpnStatus: \(vpnStatus)]")
        }
    }

}

extension VPNStatus {
    func toConnectionState() -> ConnectionState {
        switch self {
        case .connected:
            return .connected
        case .connecting:
            return .connecting
        case .disconnecting:
            return .disconnecting
        default:
            return .disconnected
        }
    }
}
