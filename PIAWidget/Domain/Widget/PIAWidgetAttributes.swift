#if !targetEnvironment(macCatalyst)

    import ActivityKit
    import Foundation

    public struct PIAConnectionAttributes: ActivityAttributes, Sendable {
        public typealias PIAConnectionStatus = ContentState

        public struct ContentState: Codable, Hashable, Sendable {
            let connected: Bool
            let regionName: String
            let regionFlag: String
            let vpnProtocol: String
        }
    }
#endif
