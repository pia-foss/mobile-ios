import Foundation

extension Bundle {
    /// The bundle holding the shared `Localizable.strings`. UI tests use it to look up the labels the app shows.
    public static var piaLocalizations: Bundle { .module }
}
