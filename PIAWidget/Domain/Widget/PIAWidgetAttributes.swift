
import Foundation
import ActivityKit

public struct PIAConnectionAttributes: ActivityAttributes {
    public typealias PIAConnectionStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var connected: Bool
        var regionName: String
        var regionFlag: String
        var vpnProtocol: String
        
    }
    
} 

