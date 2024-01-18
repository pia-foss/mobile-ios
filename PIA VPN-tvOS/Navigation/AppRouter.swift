
import Foundation

import SwiftUI


protocol AppRouterType {
    var stackCount: Int { get }
    func navigate(to destination: any Destinations)
    func pop()
    func goBackToRoot()
}

// AppRouter enables any component to navigate the user to any screen defined within Destinations
class AppRouter: ObservableObject, AppRouterType {
    
    static let shared: AppRouter = AppRouter(with: NavigationPath())
    
    @Published public var path: NavigationPath
    
    /// Returns the amount of stacked views. Useful during unit test validation
    var stackCount: Int {
        path.count
    }
    
    init(with path: NavigationPath) {
        self.path = path
    }
    
    func navigate(to destination: any Destinations) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func goBackToRoot() {
        path.removeLast(path.count)
    }
    
}


extension AppRouter {
    
    enum Actions: Equatable {
        
        case pop(router: AppRouterType)
        case goBackToRoot(router: AppRouterType)
        case navigate(router: AppRouterType, destination: any Destinations)
        
        func execute() {
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
