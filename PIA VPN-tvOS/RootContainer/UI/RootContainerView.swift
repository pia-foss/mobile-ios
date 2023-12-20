
import Foundation
import SwiftUI

struct RootContainerView: View {
    @ObservedObject var viewModel: RootContainerViewModel
    
    var body: some View {
        switch viewModel.state {
        case .splash:
            VStack {
                // TODO: Add Splash screen here
            }
        case .notActivated:
            LoginFactory.makeLoginView()
        case .activatedNotOnboarded:
            // TODO: Replace this view with the Onboarding Vpn Profile installation view
            VStack {
                Text("Show Onboarding vpn installation view")
            }
        case .activated:
            DashboardFactory.makeDashboardView()
        }
    }
    
    
}

