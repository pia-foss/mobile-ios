
import Foundation
import SwiftUI
import PIALibrary

class RootContainerViewModel: ObservableObject {
    enum State {
        case splash
        case notActivated
        case activatedNotOnboarded
        case activated
    }
    
    @Published var state: State = .splash
    @Published private var isBootstrapped: Bool = false
    
    // TODO: Update this value from the Vpn OnBoarding installation profile screen
    @AppStorage(.kOnboardingVpnProfileInstalled) var onBoardingVpnProfileInstalled = false
    
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
    
    func phaseDidBecomeActive() {
        // Bootstrap PIALibrary preferences and settings
        Bootstrapper.shared.bootstrap()
        isBootstrapped = true
        updateState()
    }
    
    private func updateState() {
        guard isBootstrapped else {
            return
        }
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

}

// NotificationCenter subscriptions

extension RootContainerViewModel {
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

extension RootContainerViewModel {
    // FIXME: this method should be in the VpnProfile installation VM object
    // Implemented in PIA-888
    func installVpnProfile() {
        let vpnProvider = Client.providers.vpnProvider
        vpnProvider.install(force: true) { error in
            NSLog("Install VPN profile error: \(String(describing: error))")
            if error == nil {
                self.onBoardingVpnProfileInstalled = true
            }
        }
        
    }
}
