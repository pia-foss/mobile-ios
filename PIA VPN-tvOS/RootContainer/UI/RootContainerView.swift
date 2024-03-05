
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
                SplashView()
            case .notActivated:
                WelcomeFactory.makeWelcomeView()
                    .withAuthenticationRoutes()
                    .withOnboardingRoutes()
            case .activatedNotOnboarded, .activated:
                UserActivatedContainerFactory.makeUSerActivatedContainerView()
                    .withOnboardingRoutes()
            }
        }.onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.sceneDidBecomeActive()
            default:
                break
            }
        }
    }
}

