import Foundation

extension CharacterSet {
    /// The RFC 3986 *unreserved* set — the only characters that never need escaping in a URI
    /// component. Everything else, `+` `/` `=` included, gets percent-encoded. Foundation's
    /// `.urlQueryAllowed` is far more permissive and leaves all three intact.
    static let rfc3986Unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}
