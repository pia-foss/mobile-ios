

import Foundation
import Combine
import SwiftUI

class DashboardViewModel: ObservableObject {
    
    @Published var connectionTitle: String?
    @Published var connectionTintColor = (titleTint: Color.clear, connectionBarTint: Color.clear)
    
    private let connectionStateMonitor: ConnectionStateMonitorType
    private var cancellables = Set<AnyCancellable>()
    
    init(connectionStateMonitor: ConnectionStateMonitorType) {
        self.connectionStateMonitor = connectionStateMonitor
        subscribeToConnectionStateUpdates()
    }
    
    private func subscribeToConnectionStateUpdates() {
        connectionStateMonitor.connectionStatePublisher
            .sink { [weak self] newConnectionState in
                guard let self else { return }
                self.connectionTitle = newConnectionState.title
                self.connectionTintColor = self.getTintColor(for: newConnectionState)
            }.store(in: &cancellables)
    }
    
    internal func getTintColor(for connectionState: ConnectionState) -> (titleTint: Color, connectionBarTint: Color) {
        switch connectionState {
        case .connecting, .disconnecting:
            return (titleTint: .pia_yellow_dark, connectionBarTint: .pia_yellow_dark)
        case .connected:
            return (titleTint: .pia_primary, connectionBarTint: .pia_primary)
        case .disconnected:
            return (titleTint: .pia_on_surface, connectionBarTint: .clear)
        case .error(let error):
            return (titleTint: .pia_red, connectionBarTint: .pia_red)
        default:
            return (.clear, .clear)
        }
    }

}
