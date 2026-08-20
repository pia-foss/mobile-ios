import Foundation

protocol DedicatedIPTokenHandlerType: Sendable {
    func callAsFunction(dedicatedIp: DedicatedIPInformation, dipUsername: String)
}
