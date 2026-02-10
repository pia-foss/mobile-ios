import Foundation

/// Base protocol for all PIA SDK errors
public protocol PIAError: Error, LocalizedError {
    /// HTTP status code or custom error code
    var code: Int { get }

    /// The underlying error that caused this error, if any
    var underlyingError: Error? { get }
}

/// Error type for account-related operations
public struct PIAAccountError: PIAError, Sendable {
    /// HTTP status code or custom error code (600+ for local errors)
    public let code: Int

    /// Human-readable error message from the API or SDK
    public let message: String?

    /// Number of seconds to wait before retrying (from Retry-After header)
    public let retryAfterSeconds: TimeInterval

    /// The underlying error that caused this error, if any
    public let underlyingError: Error?

    public init(
        code: Int,
        message: String?,
        retryAfterSeconds: TimeInterval = 0,
        underlyingError: Error? = nil
    ) {
        self.code = code
        self.message = message
        self.retryAfterSeconds = retryAfterSeconds
        self.underlyingError = underlyingError
    }

    // MARK: - LocalizedError

    public var errorDescription: String? {
        if let message = message {
            return message
        }
        return HTTPURLResponse.localizedString(forStatusCode: code)
    }

    public var failureReason: String? {
        if retryAfterSeconds > 0 {
            return "Retry after \(Int(retryAfterSeconds)) seconds"
        }
        return nil
    }

    // MARK: - Factory Methods

    /// Creates an error from an HTTP status code and optional response data
    public static func fromHTTPStatus(
        _ status: Int,
        data: Data? = nil,
        retryAfter: TimeInterval = 0
    ) -> PIAAccountError {
        let message = data.flatMap { parseErrorMessage(from: $0) }
        return PIAAccountError(
            code: status,
            message: message,
            retryAfterSeconds: retryAfter,
            underlyingError: nil
        )
    }

    /// Creates an unauthorized error (401)
    public static func unauthorized() -> PIAAccountError {
        return PIAAccountError(
            code: 401,
            message: "Invalid credentials or authentication required",
            retryAfterSeconds: 0,
            underlyingError: nil
        )
    }

    /// Creates a network failure error (600)
    public static func networkFailure(_ error: Error) -> PIAAccountError {
        return PIAAccountError(
            code: 600,
            message: "Network request failed: \(error.localizedDescription)",
            retryAfterSeconds: 0,
            underlyingError: error
        )
    }

    /// Creates a decoding failure error (601)
    public static func decodingFailed(_ error: Error) -> PIAAccountError {
        return PIAAccountError(
            code: 601,
            message: "Failed to decode response: \(error.localizedDescription)",
            retryAfterSeconds: 0,
            underlyingError: error
        )
    }

    /// Creates an encoding failure error (602)
    public static func encodingFailed(_ error: Error) -> PIAAccountError {
        return PIAAccountError(
            code: 602,
            message: "Failed to encode request: \(error.localizedDescription)",
            retryAfterSeconds: 0,
            underlyingError: error
        )
    }

    /// Creates a configuration error (603)
    public static func configurationError(_ message: String) -> PIAAccountError {
        return PIAAccountError(
            code: 603,
            message: message,
            retryAfterSeconds: 0,
            underlyingError: nil
        )
    }

    /// Creates a keychain error (604)
    public static func keychainError(_ message: String, osStatus: OSStatus) -> PIAAccountError {
        return PIAAccountError(
            code: 604,
            message: "\(message) (status: \(osStatus))",
            retryAfterSeconds: 0,
            underlyingError: nil
        )
    }

    /// Creates a certificate pinning failure error (605)
    public static func certificatePinningFailed(_ reason: String) -> PIAAccountError {
        return PIAAccountError(
            code: 605,
            message: "Certificate pinning failed: \(reason)",
            retryAfterSeconds: 0,
            underlyingError: nil
        )
    }

    // MARK: - Private Helpers

    private static func parseErrorMessage(from data: Data) -> String? {
        // Try to parse JSON error response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        // Look for common error message keys
        if let message = json["message"] as? String {
            return message
        }
        if let error = json["error"] as? String {
            return error
        }
        if let errorDescription = json["error_description"] as? String {
            return errorDescription
        }

        return nil
    }
}

/// Error type for multiple endpoint failures
public struct PIAMultipleErrors: PIAError, Sendable {
    /// Array of individual endpoint errors
    public let errors: [PIAAccountError]

    public init(errors: [PIAAccountError]) {
        self.errors = errors
    }

    // MARK: - PIAError

    public var code: Int {
        errors.first?.code ?? 600
    }

    public var underlyingError: Error? {
        errors.first
    }

    // MARK: - LocalizedError

    public var errorDescription: String? {
        if errors.isEmpty {
            return "Multiple unknown errors occurred"
        }
        if errors.count == 1, let first = errors.first {
            return first.errorDescription
        }
        let codes = errors.map { String($0.code) }.joined(separator: ", ")
        return "Multiple endpoint failures (codes: \(codes))"
    }

    public var failureReason: String? {
        if let firstError = errors.first {
            return "First error: \(firstError.errorDescription ?? "Unknown")"
        }
        return nil
    }

    /// Returns the primary error (first in the list)
    public var primaryError: PIAAccountError? {
        errors.first
    }
}

// MARK: - HTTP Status Code Helpers

extension PIAAccountError {
    /// Checks if the error is a client error (4xx)
    public var isClientError: Bool {
        (400...499).contains(code)
    }

    /// Checks if the error is a server error (5xx)
    public var isServerError: Bool {
        (500...599).contains(code)
    }

    /// Checks if the error is a network/local error (600+)
    public var isLocalError: Bool {
        code >= 600
    }

    /// Checks if the error suggests the request can be retried
    public var isRetryable: Bool {
        // Retry on server errors, timeout, and certain client errors
        isServerError || code == 408 || code == 429 || isLocalError
    }
}
