
import Foundation
import PIALibrary

class RootContainerFactory {
    static func makeRootContainerView() -> RootContainerView {
        RootContainerView(viewModel: makeRootContainerViewModel(), appRouter: AppRouter.shared)
    }
    
    private static func makeRootContainerViewModel() -> RootContainerViewModel {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        return RootContainerViewModel(accountProvider: defaultAccountProvider,
                                      vpnConfigurationAvailability: VPNConfigurationAvailability(),
                                      connectionStatsPermissonType: ConnectionStatsPermisson(),
                                      bootstrap: BootstraperFactory.makeBootstrapper(),
                                      userAuthenticationStatusMonitor: StateMonitorsFactory.makeUserAuthenticationStatusMonitor(),
                                      appRouter: AppRouterFactory.makeAppRouter())
    }
}
