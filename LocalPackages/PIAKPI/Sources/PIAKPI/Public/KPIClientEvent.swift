import Foundation

public struct KPIClientEvent: Sendable {
    public let eventCountry: String?
    public let eventName: String
    public let eventProperties: [String: String]
    public let eventInstant: Date

    public init(
        eventCountry: String? = nil,
        eventName: String,
        eventProperties: [String: String],
        eventInstant: Date
    ) {
        self.eventCountry = eventCountry
        self.eventName = eventName
        self.eventProperties = eventProperties
        self.eventInstant = eventInstant
    }
}
