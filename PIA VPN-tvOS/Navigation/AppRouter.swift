
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
