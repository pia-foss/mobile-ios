
import Foundation

import SwiftUI


// AppRouter enables any component to navigate the user to any screen defined within Destinations
class AppRouter: ObservableObject {
    
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
