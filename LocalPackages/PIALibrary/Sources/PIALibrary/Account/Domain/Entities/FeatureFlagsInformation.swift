
import Foundation


struct FeatureFlagsInformation: Codable {
    let flags: [String]
}

extension FeatureFlagsInformation {
    static func makeWith(data: Data) -> FeatureFlagsInformation? {
        try? JSONDecoder().decode(FeatureFlagsInformation.self, from: data)
    }
}


