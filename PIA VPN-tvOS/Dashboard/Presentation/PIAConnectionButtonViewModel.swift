

import Foundation
import SwiftUI
import PIALibrary
import Combine



class PIAConnectionButtonViewModel: ObservableObject {

    
    @Published var state: ConnectionState = .disconnected
    var animating: Bool {
        state == .connecting || state == .disconnecting
    }
    
    @Published var isShowingErrorAlert: Bool = false
    
    private let vpnConnectionUseCase: VpnConnectionUseCaseType
    private let connectionStateMonitor: ConnectionStateMonitorType
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: VpnConnectionUseCaseType, connectionStateMonitor: ConnectionStateMonitorType) {
        self.vpnConnectionUseCase = useCase
        self.connectionStateMonitor = connectionStateMonitor
        
        addObservers()
    }
    
    var errorAlertTitle: String {
        L10n.Localizable.ErrorAlert.ConnectionError.NoNetwork.title
    }
    
    var errorAlertMessage: String {
        L10n.Localizable.ErrorAlert.ConnectionError.NoNetwork.message
    }
    
    var errorAlertRetryActionTitle: String {
        L10n.Localizable.ErrorAlert.ConnectionError.NoNetwork.RetryAction.title
    }
    
    var errorAlertCloseActionTitle: String {
        L10n.Localizable.Global.close
    }
    
    
    private func addObservers() {
        connectionStateMonitor.connectionStatePublisher
            .sink { newConnectionState in
                self.state = newConnectionState
            }.store(in: &cancellables)
        
    }
    
    var tintColor: Color {
        switch state {
        case .disconnected:
            return .pia_yellow_dark
        case .connecting, .disconnecting:
            return .pia_yellow_dark
        case .connected:
            return .pia_primary
        case .error:
            return .pia_red
        default:
            return .pia_yellow_dark
        }
    }
    
}

// MARK: Connection

extension PIAConnectionButtonViewModel {
    
    func toggleConnection() {
        switch state {
        case .disconnected:
            connect()
        case .connecting:
            disconnect()
        case .connected:
            disconnect()
        case .disconnecting, .unkown:
            break
        case .error:
            connect()
        }
    }
    
    private func connect() {
        Task {
            do {
               try await vpnConnectionUseCase.connect()
            } catch {
                DispatchQueue.main.async {
                    self.isShowingErrorAlert = true
                }
            }
        }
    }
    
    private func disconnect() {
        Task {
            try await vpnConnectionUseCase.disconnect()
        }
        
    }
}

