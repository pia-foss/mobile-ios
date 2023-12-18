

import Foundation
import SwiftUI
import PIALibrary

class DashboardViewModel: ObservableObject {
    
    let accountProvider: AccountProvider
    
    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    func logOut() {
        accountProvider.logout { error in
            if let err = error {
                NSLog("DashboardViewModel: logout error: \(err)")
            }
        }
    }
    
}
