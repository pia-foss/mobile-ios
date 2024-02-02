
import Foundation
import SwiftUI

struct RootContainerView: View {
    @ObservedObject var viewModel: RootContainerViewModel
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject private var appRouter: AppRouter
    
    init(viewModel: RootContainerViewModel, appRouter: AppRouter) {
        self.viewModel = viewModel
        self.appRouter = appRouter
    }
    
    var body: some View {
        NavigationStack(path: $appRouter.path) {
                // Add a root view here.
                switch viewModel.state {
                case .splash:
                    VStack {
                        // TODO: Add Splash screen here
                    }
                case .notActivated:
                    LoginFactory.makeLoginView()
                        .withAuthenticationRoutes()
                        .withOnboardingRoutes()
                case .activatedNotOnboarded, .activated:
                    UserActivatedContainerFactory.makeUSerActivatedContainerView()
                        .withOnboardingRoutes()
                }
        }.onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                NSLog(">>> Active")
            } else if newPhase == .inactive {
                NSLog(">>> Inactive")
            } else if newPhase == .background {
                NSLog(">>> Background")
            }
        }
    }
}

