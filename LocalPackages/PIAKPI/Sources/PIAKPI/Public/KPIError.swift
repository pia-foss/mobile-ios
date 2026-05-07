import Foundation

public struct KPIError: Error, CustomStringConvertible, Sendable, Equatable {
    public let description: String

    public init(description: String) {
        self.description = description
    }
}
