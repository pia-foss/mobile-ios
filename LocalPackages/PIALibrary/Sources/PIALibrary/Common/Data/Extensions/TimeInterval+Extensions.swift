
import Foundation

extension TimeInterval {
    func inMinutes() -> Double {
        return (self / 60)
    }
    
    func inHours() -> Double {
        return (inMinutes() / 60)
    }
    
    func inDays() -> Double {
        return (inHours() / 24)
    }
}
