

import Foundation

class DashboardViewModel: ObservableObject {
    
    private let accountProvider: AccountProviderType
    private let appRouter: AppRouter
    
    
    init(accountProvider: AccountProviderType, appRouter: AppRouter) {
        self.accountProvider = accountProvider
        self.appRouter = appRouter
    }
    
    func regionSelectionSectionWasTapped() {
        appRouter.navigate(to: RegionsDestinations.serversList)
    }
    
    
    // TODO: Remove this functionality from Dashboard when we have it on the settings menu
    func logOut() {
        accountProvider.logout(nil)
    }
    
}
