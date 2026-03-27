import SwiftUI

public extension Asset {
    /// Returns the flag SwiftUI Image for the given ISO 3166-1 alpha-2 country code, or `nil` if not found.
    static func flag(forCountry country: String) -> Image? {
        guard let uiImage = UIImage(named: "flag-\(country.lowercased())", in: Bundle.module, with: nil) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}
