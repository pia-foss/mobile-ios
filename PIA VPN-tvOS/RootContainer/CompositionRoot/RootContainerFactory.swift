
import Foundation
import PIALibrary

class RootContainerFactory {
    static func makeRootContainerView() -> RootContainerView {
        RootContainerView(viewModel: makeRootContainerViewModel(), appRouter: AppRouter.shared)
    }
    
    private static func makeRootContainerViewModel() -> RootContainerViewModel {
        return RootContainerViewModel(accountProvider: SettingsFactory.makeDefaultAccountProvider(),
                                      vpnConfigurationAvailability: VPNConfigurationAvailability(),
                                      connectionStatsPermissonType: ConnectionStatsPermisson(),
                                      bootstrap: BootstraperFactory.makeBootstrapper(),
                                      userAuthenticationStatusMonitor: StateMonitorsFactory.makeUserAuthenticationStatusMonitor,
                                      connectionStateMonitor: StateMonitorsFactory.makeConnectionStateMonitor,
                                      appRouter: AppRouterFactory.makeAppRouter())
    }
}
