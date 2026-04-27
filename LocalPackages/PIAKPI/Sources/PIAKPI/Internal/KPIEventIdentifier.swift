import Foundation

struct KPIEventIdentifier: Codable, Sendable, Equatable {
    let aggregatedId: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case aggregatedId = "aggregated_id"
        case createdAt = "created_at"
    }
}
