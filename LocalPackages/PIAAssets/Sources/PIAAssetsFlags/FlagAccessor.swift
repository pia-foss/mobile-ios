import SwiftUI
import UIKit

public enum Flag {
    /// Returns the flag for the given ISO 3166-1 alpha-2 country code, or `nil` if not found.
    public static func image(forCountry country: String) -> UIImage? {
        UIImage(named: "flag-\(country.lowercased())", in: Bundle.module, with: nil)
    }

    /// Returns the flag as a SwiftUI `Image`, or `nil` if not found.
    public static func swiftUIImage(forCountry country: String) -> Image? {
        image(forCountry: country).map(Image.init(uiImage:))
    }
}
