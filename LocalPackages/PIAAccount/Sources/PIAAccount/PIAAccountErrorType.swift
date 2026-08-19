import Foundation

/// Types of errors in Account SDK, including HTTP status codes.
public enum PIAAccountErrorType: Equatable, Sendable {
    case network
    case decoding
    case encoding
    case configuration
    case keychain
    case certificatePinning
    case http(status: Int)

    /// Internal error code or HTTP status.
    public var code: Int {
        return switch self {
        case .network: 600
        case .decoding: 601
        case .encoding: 602
        case .configuration: 603
        case .keychain: 604
        case .certificatePinning: 605
        case .http(let status): status
        }
    }
}
