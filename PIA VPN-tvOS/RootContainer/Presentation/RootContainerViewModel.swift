
import Foundation
import SwiftUI
import PIALibrary
import Combine

class RootContainerViewModel: ObservableObject {
    enum State {
        case splash
        case notActivated
        case activatedNotOnboarded
        case activated
    }
    
    @Published var state: State = .splash
    @Published internal var isBootstrapped: Bool = false
    
    private let accountProvider: AccountProviderType
    private let notificationCenter: NotificationCenterType
    private let vpnConfigurationAvailability: VPNConfigurationAvailabilityType
    private let bootstrap: BootstraperType
    private let userAuthenticationStatusMonitor: UserAuthenticationStatusMonitorType
    private let appRouter: AppRouterType
    private var cancellables = Set<AnyCancellable>()
    
    init(accountProvider: AccountProviderType, notificationCenter: NotificationCenterType = NotificationCenter.default, vpnConfigurationAvailability: VPNConfigurationAvailabilityType, bootstrap: BootstraperType, userAuthenticationStatusMonitor: UserAuthenticationStatusMonitorType, appRouter: AppRouterType) {
        
        self.accountProvider = accountProvider
        self.notificationCenter = notificationCenter
        self.vpnConfigurationAvailability = vpnConfigurationAvailability
        self.bootstrap = bootstrap
        self.userAuthenticationStatusMonitor = userAuthenticationStatusMonitor
        self.appRouter = appRouter
        
        subscribeToAccountUpdates()
        setup()
    }
    
    private func setup() {
        bootstrap()
        isBootstrapped = true
        updateState()
    }
    
    @objc private func updateState() {
        guard isBootstrapped else {
            return
        }
        
        let onBoardingVpnProfileInstalled = vpnConfigurationAvailability.get()
        
        switch (accountProvider.isLoggedIn, onBoardingVpnProfileInstalled) {
            // logged in, vpn profile installed
        case (true, true):
            state = .activated
            // logged in, vpn profile not installed
        case (true, false):
            state = .activatedNotOnboarded
            appRouter.navigate(to: OnboardingDestinations.installVPNProfile)
            // not logged in, any
        case (false, _):
            state = .notActivated
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

// Combine subscriptions

extension RootContainerViewModel {
    private func subscribeToAccountUpdates() {
        userAuthenticationStatusMonitor.getStatus().sink { status in
            self.updateState()
        }.store(in: &cancellables)
        
        notificationCenter.addObserver(self,
                         selector: #selector(updateState),
                         name: .DidInstallVPNProfile,
                         object: nil)
    }
}
