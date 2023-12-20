

import Foundation

class DashboardViewModel: ObservableObject {
    
    let accountProvider: AccountProviderType
    
    init(accountProvider: AccountProviderType) {
        self.accountProvider = accountProvider
    }
    
    func logOut() {
        accountProvider.logout(nil)
    }
    
}
