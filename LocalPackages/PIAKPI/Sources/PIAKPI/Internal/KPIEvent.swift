import Foundation

struct KPIEvent: Codable, Sendable, Equatable {
    let aggregatedId: String
    let uniqueId: String
    let eventCountry: String?
    let eventName: String
    let eventProperties: [String: String]
    let eventTime: Int64
    let eventToken: String

    enum CodingKeys: String, CodingKey {
        case aggregatedId = "aggregated_id"
        case uniqueId = "event_unique_id"
        case eventCountry = "event_country"
        case eventName = "event_name"
        case eventProperties = "event_properties"
        case eventTime = "event_time"
        case eventToken = "event_token"
    }
}
