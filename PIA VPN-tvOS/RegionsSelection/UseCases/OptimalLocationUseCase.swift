//
//  OptimalLocationUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/20/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
import PIALibrary

private let log = PIALogger.logger(for: OptimalLocationUseCase.self)

protocol OptimalLocationUseCaseType {
    var optimalLocation: ServerType { get }
    func getTargetLocaionForOptimalLocation() -> AnyPublisher<ServerType?, Never>
}

class OptimalLocationUseCase: OptimalLocationUseCaseType {
    
    private let serverProvider: ServerProviderType
    private let vpnStatusMonitor: VPNStatusMonitorType
    private let selectedServerUseCase: SelectedServerUseCaseType
    private var cancellables = Set<AnyCancellable>()
    
    var optimalLocation: ServerType {
        Server.automatic
    }
    
    private var targetServerForOptimalLocation: CurrentValueSubject<ServerType?, Never>
    
    init(serverProvider: ServerProviderType, vpnStatusMonitor: VPNStatusMonitorType, selectedServerUseCase: SelectedServerUseCaseType) {
        self.serverProvider = serverProvider
        self.vpnStatusMonitor = vpnStatusMonitor
        self.selectedServerUseCase = selectedServerUseCase
        self.targetServerForOptimalLocation = CurrentValueSubject(nil)
        subscribeToVpnStatusUpdate()
    }
    
    func getTargetLocaionForOptimalLocation() -> AnyPublisher<ServerType?, Never> {
        return targetServerForOptimalLocation.eraseToAnyPublisher()
    }
    
}

// MARK: - Subscription updates

extension OptimalLocationUseCase {
    private func subscribeToVpnStatusUpdate() {
        vpnStatusMonitor.getStatus()
            .combineLatest(selectedServerUseCase.getSelectedServer()) { newVpnStatus, newSelectedServer in
                return (vpnStatus: newVpnStatus, selectedServer: newSelectedServer)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result.vpnStatus {
                case .connecting, .connected:
                    if result.selectedServer.isAutomatic {
                        do {
                            let targetServerType = try serverProvider.targetServerType
                            targetServerForOptimalLocation.send(targetServerType)
                        } catch {
                            log.error("Failed to get targetServerType: \(error.localizedDescription)")
                        }
                    } else {
                        self.targetServerForOptimalLocation.send(nil)
                    }
                default:
                    self.targetServerForOptimalLocation.send(nil)
                }
            }.store(in: &cancellables)
    }
}
