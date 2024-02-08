

import Foundation
import SwiftUI
import PIALibrary
import Combine

extension VPNStatus {
    func toConnectionButtonState() -> PIAConnectionButtonViewModel.State {
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

class PIAConnectionButtonViewModel: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }
    
    @Published var state: State = .disconnected
    
    private let vpnConnectionUseCase: VpnConnectionUseCaseType
    private let vpnStatusMonitor: VPNStatusMonitorType
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: VpnConnectionUseCaseType, vpnStatusMonitor: VPNStatusMonitorType) {
        self.vpnConnectionUseCase = useCase
        self.vpnStatusMonitor = vpnStatusMonitor
        
        addObservers()
    }
    
    private func addObservers() {
        vpnStatusMonitor.getStatus().sink { [weak self] vpnStatus in
            self?.state = vpnStatus.toConnectionButtonState()
        }.store(in: &cancellables)
    }
    
    // Inner ring color and outer ring color
    var tintColor: (Color, Color) {
        switch state {
        case .disconnected:
            return (.pia_red_dark, .pia_red_dark)
        case .connecting, .disconnecting:
            return (.pia_yellow_dark, .pia_surface_container_secondary)
        case .connected:
            return (.pia_primary, .pia_primary)
        }
    }
    
    var animating: Bool {
        state == .connecting ||
        state == .disconnecting
    }
}

// MARK: Connection

extension PIAConnectionButtonViewModel {
    
    func toggleConnection() {
        switch state {
        case .disconnected:
            connect()
        case .connecting:
            break
        case .connected:
            disconnect()
        case .disconnecting:
            break
        }
    }
    
    private func connect() {
        vpnConnectionUseCase.connect()
    }
    
    private func disconnect() {
        vpnConnectionUseCase.disconnect()
    }
}

