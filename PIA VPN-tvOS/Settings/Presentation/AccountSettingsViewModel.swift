//
//  AccountSettingsViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: AccountSettingsViewModel.self)

class AccountSettingsViewModel: ObservableObject {
    
    @Published var isLogOutAlertVisible: Bool = false
    @Published var isLoading: Bool = false

    let accountProvider: AccountProvider
    let logOutUseCase: LogOutUseCaseType
    
    internal var expiryState: ExipryState = .unknown
    
    internal enum ExipryState: Equatable {
        case unknown
        case expired
        case notExpired
    }
    
    init(accountProvider: AccountProvider, logOutUseCase: LogOutUseCaseType) {
        self.accountProvider = accountProvider
        self.logOutUseCase = logOutUseCase
        self.expiryState = getCurrentExpirtyState()
    }
    
    func logOutButtonWasTapped() {
        isLogOutAlertVisible = true
    }
    
    private func getCurrentExpirtyState() -> ExipryState {
        guard let userInfo = accountProvider.currentUser?.info else {
            return .unknown
        }
        
        if userInfo.isExpired {
            return .expired
        } else {
            return .notExpired
        }
    }
    
    private func setLoading(to loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = loading
        }
    }
    
    func logOutConfirmationButtonWasTapped() {
        log.info("Logout confirmed")
        Task {
            do {
                setLoading(to: true)
                try await logOutUseCase.logOut()
                log.info("Logout succeeded")
                setLoading(to: false)
            } catch {
                log.error("Logout failed: \(error.localizedDescription)")
                setLoading(to: false)
            }
        }
    }
    
}

// MARK: - Localization

extension AccountSettingsViewModel {
    var usernameTitle: String {
        L10n.Account.Username.caption
    }
    
    var usernameValue: String {
        guard let username = accountProvider.publicUsername else {
            return ""
        }
        
        return username
    }
    
    var subscriptionTitle: String {
        switch expiryState {
        case .unknown:
            return ""
        case .expired:
            return L10n.Account.ExpiryDate.expired
        case .notExpired:
            return L10n.Settings.Account.SubscriptionExpiry.title
        }
    }
    
    var subscriptionValue: String {
        guard expiryState == .notExpired,
            let userInfo = accountProvider.currentUser?.info else {
            return ""
        }
        
        return userInfo.humanReadableExpirationDate()
    }
    
    var logOutButtonTitle: String {
        L10n.Settings.Account.LogOutButton.title
    }

    var logOutAlertTitle: String {
        L10n.Settings.Account.LogOutAlert.title
    }
    
    var logOutAlertMesage: String {
        L10n.Settings.Account.LogOutAlert.message
    }
    
    var logOutAlertCancelActionText: String {
        L10n.Global.cancel
    }
    
    var logOutAlertConfirmActionText: String {
        L10n.Settings.Account.LogOutButton.title
    }
    
}
