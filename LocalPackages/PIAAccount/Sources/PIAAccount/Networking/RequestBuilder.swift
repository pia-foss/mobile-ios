import Foundation

/// HTTP request builder with support for form parameters and JSON body
struct RequestBuilder {
    enum HTTPMethod: String, Sendable {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    enum BodyType: Sendable {
        case json(Data)
        case formEncoded([String: String])
    }

    /// Builds a URLRequest with the specified parameters
    /// - Parameters:
    ///   - url: The request URL
    ///   - method: The HTTP method
    ///   - bodyType: The body type (JSON or form-encoded), if any
    ///   - headers: Additional HTTP headers
    /// - Returns: A configured URLRequest
    static func build(
        url: URL,
        method: HTTPMethod,
        bodyType: BodyType? = nil,
        headers: [String: String] = [:]
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Set body and content type based on body type
        switch bodyType {
        case .json(let data):
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        case .formEncoded(let params):
            request.httpBody = params.urlEncodedData()
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        case .none:
            break
        }

        return request
    }
}

// MARK: - Form Encoding Helpers

extension Dictionary where Key == String, Value == String {
    /// Converts a dictionary to URL-encoded form data
    func urlEncodedData() -> Data? {
        // Create character set for form encoding (RFC 3986)
        // We need to encode everything except unreserved characters (A-Z a-z 0-9 - _ . ~)
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: "-_.~")

        let encodedPairs = self.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }
        let encodedString = encodedPairs.joined(separator: "&")
        return encodedString.data(using: .utf8)
    }
}
