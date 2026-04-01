//
//  UserAuthenticationStatusMonitor.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine

protocol UserAuthenticationStatusMonitorType {
    func getStatus() -> AnyPublisher<UserAuthenticationStatus, Never>
}

enum UserAuthenticationStatus {
    case loggedIn
    case loggedOut
}

class UserAuthenticationStatusMonitor: UserAuthenticationStatusMonitorType {
    private var status: CurrentValueSubject<UserAuthenticationStatus, Never>
    private let notificationCenter: NotificationCenterType
    
    init(currentStatus: UserAuthenticationStatus, notificationCenter: NotificationCenterType) {
        self.notificationCenter = notificationCenter
        
        self.status = CurrentValueSubject<UserAuthenticationStatus, Never>(currentStatus)
        
        addObservers()
    }
    
    
    private func addObservers() {
        notificationCenter.addObserver(self, selector: #selector(handleAccountDidLogin), name: .PIAAccountDidLogin, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(handleAccountDidLogout), name: .PIAAccountDidLogout, object: nil)
    }
    
    @objc func handleAccountDidLogin() {
        if status.value != .loggedIn {
            status.send(.loggedIn)
        }
    }
    
    @objc func handleAccountDidLogout() {
        status.send(.loggedOut)
    }
    
    func getStatus() -> AnyPublisher<UserAuthenticationStatus, Never> {
        return status.eraseToAnyPublisher()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}
