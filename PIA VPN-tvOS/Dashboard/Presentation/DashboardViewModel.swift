

import Foundation

class DashboardViewModel: ObservableObject {
    
    private let accountProvider: AccountProviderType
    private let appRouter: AppRouter
    private let navigationDestination: any Destinations
    
    init(accountProvider: AccountProviderType, appRouter: AppRouter, navigationDestination: any Destinations) {
        self.accountProvider = accountProvider
        self.appRouter = appRouter
        self.navigationDestination = navigationDestination
    }
    
    
    // TODO: Remove this functionality from Dashboard when we have it on the settings menu
    func logOut() {
        accountProvider.logout(nil)
    }
    
}
