import Foundation

/// Actor-based HTTP client for making API requests with optional certificate pinning
actor AccountHTTPClient {
    private let session: URLSession
    private let certificatePinner: CertificatePinner?
    private let userAgent: String

    private static let requestTimeout: TimeInterval = 3.0  // 3 seconds (matches KMP)

    /// Creates an HTTP client
    /// - Parameters:
    ///   - certificate: Optional PEM certificate for pinning
    ///   - hostname: Optional hostname for certificate validation
    ///   - commonName: Optional common name for certificate validation
    ///   - userAgent: User-Agent header value
    init(
        certificate: String?,
        hostname: String? = nil,
        commonName: String? = nil,
        userAgent: String
    ) {
        self.userAgent = userAgent

        // Configure URLSession
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Self.requestTimeout
        config.httpAdditionalHeaders = ["User-Agent": userAgent]

        // Set up certificate pinning if certificate is provided
        if let certificate = certificate {
            let pinner = CertificatePinner(
                certificate: certificate,
                hostname: hostname,
                commonName: commonName
            )
            self.certificatePinner = pinner
            self.session = URLSession(
                configuration: config,
                delegate: pinner,
                delegateQueue: nil
            )
        } else {
            self.certificatePinner = nil
            self.session = URLSession(configuration: config)
        }
    }

    // MARK: - Request Execution

    /// Executes a request and decodes the response
    /// - Parameters:
    ///   - request: The URLRequest to execute
    ///   - decoder: JSON decoder (defaults to snake_case decoder)
    /// - Returns: The decoded response
    /// - Throws: PIAAccountError if the request fails
    func execute<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = .piaCodable
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PIAAccountError.networkFailure(
                    NSError(domain: "PIAAccount", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid response type"
                    ])
                )
            }

            // Check for error status codes
            guard !URLBuilder.isErrorStatusCode(httpResponse.statusCode) else {
                throw mapHTTPStatusToError(httpResponse, data: data)
            }

            // Decode the response
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw PIAAccountError.decodingFailed(error)
            }
        } catch let error as PIAAccountError {
            throw error
        } catch {
            throw PIAAccountError.networkFailure(error)
        }
    }

    /// Executes a request without expecting a response body
    /// - Parameter request: The URLRequest to execute
    /// - Throws: PIAAccountError if the request fails
    func executeVoid(request: URLRequest) async throws {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PIAAccountError.networkFailure(
                    NSError(domain: "PIAAccount", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Invalid response type"
                    ])
                )
            }

            // Check for error status codes
            guard !URLBuilder.isErrorStatusCode(httpResponse.statusCode) else {
                throw mapHTTPStatusToError(httpResponse, data: data)
            }
        } catch let error as PIAAccountError {
            throw error
        } catch {
            throw PIAAccountError.networkFailure(error)
        }
    }

    // MARK: - Error Mapping

    private func mapHTTPStatusToError(_ response: HTTPURLResponse, data: Data) -> PIAAccountError {
        let retryAfter = parseRetryAfter(from: response, data: data)
        return PIAAccountError.fromHTTPStatus(
            response.statusCode,
            data: data,
            retryAfter: retryAfter
        )
    }

    private func parseRetryAfter(from response: HTTPURLResponse, data: Data) -> TimeInterval {
        // Check Retry-After header
        if let retryAfterHeader = response.value(forHTTPHeaderField: "Retry-After"),
           let seconds = TimeInterval(retryAfterHeader) {
            return seconds
        }

        // Check for retry_after in JSON response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let retryAfter = json["retry_after"] as? TimeInterval {
            return retryAfter
        }

        return 0
    }
}

// MARK: - JSON Decoder Configuration

extension JSONDecoder {
    /// Preconfigured decoder for PIA API responses (snake_case conversion)
    static let piaCodable: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

// MARK: - JSON Encoder Configuration

extension JSONEncoder {
    /// Preconfigured encoder for PIA API requests (snake_case conversion)
    static let piaCodable: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}
