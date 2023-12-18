
import Foundation
import SwiftUI

struct RootContainerView: View {
    @ObservedObject var viewModel: RootContainerViewModel
    
    var body: some View {
        switch viewModel.state {
        case .splash:
            VStack {
                Text("Splash Screen")
            }
        case .notActivated:
            LoginFactory.makeLoginView()
        case .activatedNotOnboarded:
            VStack {
                Text("Show Onboarding vpn installation view")
            }
        case .activated:
            DashboardFactory.makeDashboardView()
        }
    }
    
    
}

