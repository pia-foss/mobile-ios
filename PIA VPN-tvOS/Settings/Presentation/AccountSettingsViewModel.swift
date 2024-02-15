//
//  AccountSettingsViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/15/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class AccountSettingsViewModel: ObservableObject {
    
    var logOutButtonTitle: String {
        L10n.Localizable.Settings.Account.LogOutButton.title
    }

    var logOutAlertTitle: String {
        L10n.Localizable.Settings.Account.LogOutAlert.title
    }
    
    var logOutAlertMesage: String {
        L10n.Localizable.Settings.Account.LogOutAlert.message
    }
    
    var logOutAlertCancelActionText: String {
        L10n.Localizable.Global.cancel
    }
    
    var logOutAlertConfirmActionText: String {
        L10n.Localizable.Settings.Account.LogOutButton.title
    }
    
    @Published var isLogOutAlertVisible: Bool = false
    @Published var isLoading: Bool = false
    
    let logOutUseCase: LogOutUseCaseType
    
    init(logOutUseCase: LogOutUseCaseType) {
        self.logOutUseCase = logOutUseCase
    }
    
    func logOutButtonWasTapped() {
        isLogOutAlertVisible = true
    }
    
    private func setLoading(to loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = loading
        }
    }
    
    func logOutConfirmationButtonWasTapped() {
        Task {
            do {
                setLoading(to: true)
                try await logOutUseCase.logOut()
                setLoading(to: false)
            } catch {
                setLoading(to: false)
            }
        }
    }
    
}
