
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
    private let connectionStatsPermissonType: ConnectionStatsPermissonType
    private let bootstrap: BootstraperType
    private let userAuthenticationStatusMonitor: UserAuthenticationStatusMonitorType
    
    /// Inject here the connectionStateMonitor instance so we start monitoring the vpn status before creating the Dashboard view
    private let conenctionStateMonitor: ConnectionStateMonitorType
    private let appRouter: AppRouterType
    private var cancellables = Set<AnyCancellable>()
    
    init(accountProvider: AccountProviderType, notificationCenter: NotificationCenterType = NotificationCenter.default, vpnConfigurationAvailability: VPNConfigurationAvailabilityType, connectionStatsPermissonType: ConnectionStatsPermissonType, bootstrap: BootstraperType, userAuthenticationStatusMonitor: UserAuthenticationStatusMonitorType, connectionStateMonitor: ConnectionStateMonitorType, appRouter: AppRouterType) {
        
        self.accountProvider = accountProvider
        self.notificationCenter = notificationCenter
        self.vpnConfigurationAvailability = vpnConfigurationAvailability
        self.connectionStatsPermissonType = connectionStatsPermissonType
        self.bootstrap = bootstrap
        self.userAuthenticationStatusMonitor = userAuthenticationStatusMonitor
        self.conenctionStateMonitor = connectionStateMonitor
        self.appRouter = appRouter
        
        subscribeToAccountUpdates()
        setup()
    }
    
    private func setup() {
        bootstrap()
        isBootstrapped = true
        updateState(isLoggedIn: accountProvider.isLoggedIn)
    }
    
    private func updateState(isLoggedIn: Bool) {
        guard isBootstrapped else {
            return
        }
        
        let onBoardingVpnProfileInstalled = vpnConfigurationAvailability.get()
        let shouldShowconnectionStatsPermisson = connectionStatsPermissonType.get() == nil
        switch (isLoggedIn, onBoardingVpnProfileInstalled) {
            // logged in, vpn profile installed
        case (true, true):
            state = .activated
            // logged in, vpn profile not installed
        case (true, false):
            state = .activatedNotOnboarded
            if shouldShowconnectionStatsPermisson {
                appRouter.goBackToRoot()
                appRouter.navigate(to: OnboardingDestinations.connectionstats)
            } else {
                appRouter.navigate(to: OnboardingDestinations.installVPNProfile)
            }
            // not logged in, any
        case (false, _):
            state = .notActivated
            appRouter.goBackToRoot()
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
            self.updateState(isLoggedIn: status == .loggedIn)
        }.store(in: &cancellables)
        
        notificationCenter.addObserver(self,
                         selector: #selector(didInstallVPNProfile),
                         name: .DidInstallVPNProfile,
                         object: nil)
    }
    
    @objc private func didInstallVPNProfile() {
        updateState(isLoggedIn: accountProvider.isLoggedIn)
    }
}
