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

    /// How imporant the error is, when ranking in ``PIAMultipleErrors``.
    ///
    /// HTTP status are more important, since they actually reached the server.
    internal var importance: Int {
        return switch self {
        // rank 4xx higher because that's an actual response.
        case .http(400..<500): 2000
        // servers returning 5xx failed, ignoring them in favour of 4xx.
        case .http(500..<600): 1000
        // don't know how to rank the rest, but using code so they have a predictable order.
        default: code
        }
    }
}
