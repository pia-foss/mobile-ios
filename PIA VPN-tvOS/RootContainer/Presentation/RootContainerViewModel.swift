
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
        updateState()
        subscribeToAccountUpdates()
    }
    
    func phaseDidBecomeActive() {
        bootstrap()
        isBootstrapped = true
        updateState()
    }
    
    private func updateState() {
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
            appRouter.navigate(to: OnboardingDestinations.installVPNProfile)
            state = .activatedNotOnboarded
            // not logged in, any
        case (false, _):
            state = .notActivated
        }
    }

}

// Combine subscriptions

extension RootContainerViewModel {
    private func subscribeToAccountUpdates() {
        userAuthenticationStatusMonitor.getStatus().sink { status in
            self.updateState()
        }.store(in: &cancellables)
    }
}
