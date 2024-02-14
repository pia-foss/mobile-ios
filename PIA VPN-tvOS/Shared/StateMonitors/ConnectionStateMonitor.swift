//
//  ConnectionStatusMonitor.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
import PIALibrary


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
}

protocol ConnectionStateMonitorType {
    var connectionStatePublisher: Published<ConnectionState>.Publisher { get }
}

class ConnectionStateMonitor: ConnectionStateMonitorType {
    private var cancellable: AnyCancellable?
    
    private let vpnStatusMonitor: VPNStatusMonitorType
    private let vpnConnectionUseCase: VpnConnectionUseCaseType
    
    @Published private var connectionState: ConnectionState = .unkown
    var connectionStatePublisher: Published<ConnectionState>.Publisher {
        $connectionState
    }
    
    init(vpnStatusMonitor: VPNStatusMonitorType, vpnConnectionUseCase: VpnConnectionUseCaseType) {
        self.vpnStatusMonitor = vpnStatusMonitor
        self.vpnConnectionUseCase = vpnConnectionUseCase
        
        addObservers()
        
    }
    
    private func addObservers() {
        cancellable = vpnStatusMonitor.getStatus()
            .setFailureType(to: Error.self)
            .combineLatest(vpnConnectionUseCase.getConnectionIntent()) { vpnStatus, connectionIntent in
            return (status: vpnStatus, intent: connectionIntent)
        }
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let failure):
                self.connectionState = .error(failure)
            }
        }, receiveValue: { result in
            self.calculateState(for: result.intent, vpnStatus: result.status)
 
        })
    }
    
    private func calculateState(for connectionIntent: VpnConnectionIntent, vpnStatus: VPNStatus) {
        switch (connectionIntent, vpnStatus) {
        case (_, .connected):
            self.connectionState = .connected
        case (.connect, _):
            self.connectionState = .connecting
        case (_, .disconnected):
            self.connectionState = .disconnected
        case (.disconnect, _):
            self.connectionState = .disconnecting
        default:
            self.connectionState = vpnStatus.toConnectionState()
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
