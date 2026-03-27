import UIKit

public extension Asset.Flags {
    /// Returns the flag image for the given ISO 3166-1 alpha-2 country code, or `nil` if not found.
    static func flag(forCountry country: String) -> UIImage? {
        UIImage(named: "flags/flag-\(country.lowercased())", in: Bundle.module, with: nil)
    }
}
