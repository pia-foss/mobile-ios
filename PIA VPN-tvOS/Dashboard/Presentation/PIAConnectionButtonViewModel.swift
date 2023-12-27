

import Foundation
import SwiftUI

class PIAConnectionButtonViewModel: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }
    
    @Published var state: State = .disconnected
    
    private let vpnConnectionUseCase: VpnConnectionUseCaseType
    
    init(useCase: VpnConnectionUseCaseType) {
        self.vpnConnectionUseCase = useCase
    }
    
    // Inner ring color and outer ring color
    var tintColor: (Color, Color) {
        switch state {
        case .disconnected:
            return (.pia_red_dark, .pia_red_dark)
        case .connecting, .disconnecting:
            return (.pia_yellow_dark, .pia_connect_button_grey)
        case .connected:
            return (.pia_green, .pia_green)
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
        // TODO: Take the state from the real VpnManager state monitor
        state = .connecting
        
        vpnConnectionUseCase.connect()
        
        // TODO: Take the state from the real VpnManager state monitor
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            self?.state = .connected
        }
    }
    
    private func disconnect() {
        // TODO: Take the state from the real VpnManager state monitor
        state = .disconnecting
        
        vpnConnectionUseCase.disconnect()
        
        // TODO: Take the state from the real VpnManager state monitor
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            self?.state = .disconnected
        }
    }
    
}

