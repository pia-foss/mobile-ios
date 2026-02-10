import Foundation

/// Utility for building API URLs with domain/IP validation and subdomain handling
struct URLBuilder {
    private static let domainRegex = try! NSRegularExpression(
        pattern: "^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}$",
        options: []
    )

    private static let ipv4Regex = try! NSRegularExpression(
        pattern: "^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.(?!$)|$)){4}$",
        options: []
    )

    private static let stagingDomain = "staging"
    private static let scheme = "https"

    /// Builds a URL for the given endpoint and API path
    /// - Parameters:
    ///   - ipOrRootDomain: The IP address or root domain
    ///   - path: The API path to append
    /// - Returns: A valid URL
    /// - Throws: PIAAccountError if the domain/IP is invalid
    static func buildURL(ipOrRootDomain: String, path: APIPath) throws -> URL {
        // Validate that it's either a domain or IP
        guard isDomain(ipOrRootDomain) || isIPv4(ipOrRootDomain) else {
            throw PIAAccountError.configurationError(
                "Invalid domain or IP address: \(ipOrRootDomain)"
            )
        }

        let urlString: String

        // Determine URL format based on domain type
        if ipOrRootDomain.contains(stagingDomain) || isIPv4(ipOrRootDomain) {
            // For staging or IP addresses, use domain/IP as-is
            urlString = "\(scheme)://\(ipOrRootDomain)\(path.rawValue)"
        } else if isDomain(ipOrRootDomain) {
            // For normal domains, prepend subdomain
            let subdomain = path.subdomain
            urlString = "\(scheme)://\(subdomain).\(ipOrRootDomain)\(path.rawValue)"
        } else {
            throw PIAAccountError.configurationError(
                "Invalid domain or IP address: \(ipOrRootDomain)"
            )
        }

        guard let url = URL(string: urlString) else {
            throw PIAAccountError.configurationError(
                "Failed to construct URL from: \(urlString)"
            )
        }

        return url
    }

    // MARK: - Validation Helpers

    /// Checks if the string is a valid domain name
    static func isDomain(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return domainRegex.firstMatch(in: string, options: [], range: range) != nil
    }

    /// Checks if the string is a valid IPv4 address
    static func isIPv4(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return ipv4Regex.firstMatch(in: string, options: [], range: range) != nil
    }
}

// MARK: - Error Status Code Detection

extension URLBuilder {
    /// Checks if an HTTP status code represents an error
    static func isErrorStatusCode(_ code: Int) -> Bool {
        switch code {
        case 300...399:
            // Redirect response
            return true
        case 400...499:
            // Client error response
            return true
        case 500...599:
            // Server error response
            return true
        case 600...:
            // Unknown/local error response
            return true
        default:
            return false
        }
    }
}
