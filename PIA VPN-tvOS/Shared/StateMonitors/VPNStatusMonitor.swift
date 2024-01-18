//
//  VPNStatusMonitor.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
import PIALibrary

protocol VPNStatusMonitorType {
    func getStatus() -> AnyPublisher<VPNStatus, Never>
}

class VPNStatusMonitor: VPNStatusMonitorType {
    private var status: CurrentValueSubject<VPNStatus, Never>
    private let vpnStatusProvider: VPNStatusProviderType
    private let notificationCenter: NotificationCenterType
    
    init(vpnStatusProvider: VPNStatusProviderType, notificationCenter: NotificationCenterType) {
        self.vpnStatusProvider = vpnStatusProvider
        self.notificationCenter = notificationCenter
        self.status = CurrentValueSubject<VPNStatus, Never>(vpnStatusProvider.vpnStatus)
    }
    
    private func addObservers() {
        notificationCenter.addObserver(self,
                                       selector: #selector(vpnStatusDidChange(notification:)),
                                       name: .PIADaemonsDidUpdateVPNStatus,
                                       object: nil)
    }
    
    @objc func vpnStatusDidChange(notification: Notification) {
        if vpnStatusProvider.vpnStatus != status.value {
            status.send(vpnStatusProvider.vpnStatus)
        }
    }
    
    func getStatus() -> AnyPublisher<VPNStatus, Never> {
        return status.eraseToAnyPublisher()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}
