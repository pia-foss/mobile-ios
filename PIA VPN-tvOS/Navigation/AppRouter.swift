
import Foundation

import SwiftUI
import Combine

protocol AppRouterType {
    var stackCount: Int { get }
    func navigate(to destination: any Destinations)
    func pop()
    func goBackToRoot()
}


// AppRouter enables any component to navigate the user to any screen defined within Destinations
class AppRouter: ObservableObject, AppRouterType {
    
    static let shared: AppRouter = AppRouter()
    
    @Published public var path: NavigationPath
    
    /// Returns the current Destinations. Useful to find out the exact current route
    @Published private(set) var pathDestinations: [any Destinations] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Returns the amount of stacked views. Useful during unit test validation
    var stackCount: Int {
        path.count
    }
    
    init(with destinations: [any Destinations] = []) {
        self.pathDestinations = destinations
        var pathWithDestinations = NavigationPath()
        
        for destination in destinations {
            pathWithDestinations.append(destination)
        }
        self.path = pathWithDestinations
        
        subscribeToPathUpdates()
    }
    
    func navigate(to destination: any Destinations) {
        pathDestinations.append(destination)
        path.append(destination)
    }
    
    func pop() {
        pathDestinations.removeLast()
        path.removeLast()
    }
    
    func goBackToRoot() {
        pathDestinations.removeAll()
        path.removeLast(path.count)
    }
    
}


extension AppRouter {
    
    enum Actions: Equatable {
        case pop(router: AppRouterType)
        case goBackToRoot(router: AppRouterType)
        case navigate(router: AppRouterType, destination: any Destinations)
        
        func callAsFunction() {
            switch self {
            case .pop(let router):
                router.pop()
            case .goBackToRoot(let router):
                router.goBackToRoot()
            case .navigate(let router, let destination):
                router.navigate(to: destination)
            }
        }
        
        static func == (lhs: AppRouter.Actions, rhs: AppRouter.Actions) -> Bool {
            switch (lhs, rhs) {
            case (.pop, .pop):
                return true
            case (.goBackToRoot, .goBackToRoot): return true
            case (.navigate(_, destination: let lhsDestination), .navigate(_, destination: let rhsDestination)):
                return lhsDestination.hashValue == rhsDestination.hashValue
            default:
                return false
            }
        }
        
    }
}

// MARK: - Path updates subscription

extension AppRouter {
    private func subscribeToPathUpdates() {
        $path.sink { newPath in
            
            // Update the current destinations when navigating back
            if newPath.count < self.pathDestinations.count {
                self.pathDestinations.removeLast()
            }
        }.store(in: &cancellables)
    }
}

// MARK: - Destinations Navigations Actions

extension AppRouter {
    
    private static func navigateRouterToDestinationAction(_ destination: any Destinations) -> AppRouter.Actions {
        AppRouter.Actions.navigate(router: AppRouterFactory.makeAppRouter(), destination: destination)
    }
    
    static var navigateToRoot: AppRouter.Actions {
        AppRouter.Actions.goBackToRoot(router: AppRouter.shared)
    }
}

// MARK: - Onboarding Navigation Actions

extension AppRouter {
    
    static var navigateToLoginWithCredentialsDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(AuthenticationDestinations.loginCredentials)
    }
    
    static var navigateToLoginQRCodeDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(AuthenticationDestinations.loginQRCode)
    }
    
    static var navigateToSignUpDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(AuthenticationDestinations.signup)
    }
    
    static var navigateToExpiredDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(AuthenticationDestinations.expired)
    }
    
    static var navigateToConnectionstatsDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(OnboardingDestinations.connectionstats)
    }
    
    static var navigateToSignUpEmailDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(AuthenticationDestinations.signupEmail)
    }
    static var navigateToSignUpCredentialsDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(AuthenticationDestinations.signupCredentials)
    }
}

// MARK: - Settings Navigation Actions

extension AppRouter {
    
    static var navigateToAvailableSettingsDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(SettingsDestinations.availableSettings)
    }
    
    static var navigateToAccountSettingsDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(SettingsDestinations.account)
    }
    
    static var navigateToGeneralSettingsDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(SettingsDestinations.general)
    }
    
    static var navigateToDIPSettingsDestinationAction: AppRouter.Actions {
        navigateRouterToDestinationAction(SettingsDestinations.dip)
    }

}
