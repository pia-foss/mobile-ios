
import Foundation
import SwiftUI

class RootContainerViewModel: ObservableObject {
    enum State {
        case splash
        case notActivated
        case activatedNotOnboarded
        case activated
    }
    
    @Published var state: State = .splash
    
    // TODO: Update this value from the Vpn OnBoarding installation profile screen
    @AppStorage(.kOnboardingVpnProfileInstalled) var onBoardingVpnProfileInstalled = true
    
    let accountProvider: AccountProviderType
    let notificationCenter: NotificationCenterType
    
    init(accountProvider: AccountProviderType, notificationCenter: NotificationCenterType = NotificationCenter.default) {
        
        self.accountProvider = accountProvider
        self.notificationCenter = notificationCenter
        updateState()
        subscribeToAccountUpdates()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    private func updateState() {
        switch (accountProvider.isLoggedIn, onBoardingVpnProfileInstalled) {
            // logged in, vpn profile installed
        case (true, true):
            state = .activated
            // logged in, vpn profile not installed
        case (true, false):
            state = .activatedNotOnboarded
            // not logged in, any
        case (false, _):
            state = .notActivated
        }
    }
    
    private func subscribeToAccountUpdates() {
        notificationCenter.addObserver(self, selector: #selector(handleAccountDidLogin), name: .PIAAccountDidLogin, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(handleAccountDidLogout), name: .PIAAccountDidLogout, object: nil)
    }
    
    @objc func handleAccountDidLogin() {
        updateState()
    }
    
    @objc func handleAccountDidLogout() {
        updateState()
    }
    
    
}
