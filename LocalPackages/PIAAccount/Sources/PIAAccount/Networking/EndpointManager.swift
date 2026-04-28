import Foundation

/// Manages multi-endpoint failover for API requests
actor EndpointManager {
    private let endpointProvider: PIAAccountEndpointProvider
    private let certificate: String?
    private let userAgent: String

    /// Creates an endpoint manager
    /// - Parameters:
    ///   - endpointProvider: Provider for the list of endpoints
    ///   - certificate: Optional certificate for pinning
    ///   - userAgent: User-Agent header value
    init(
        endpointProvider: PIAAccountEndpointProvider,
        certificate: String?,
        userAgent: String
    ) {
        self.endpointProvider = endpointProvider
        self.certificate = certificate
        self.userAgent = userAgent
    }

    // MARK: - Request Execution with Failover

    /// Executes a request with automatic failover across multiple endpoints
    /// - Parameters:
    ///   - path: The API path
    ///   - method: HTTP method
    ///   - bodyType: Request body type (JSON or form-encoded)
    ///   - headers: Additional HTTP headers
    ///   - queryParameters: Optional query parameters to append to URL
    ///   - decoder: JSON decoder for response
    /// - Returns: The decoded response
    /// - Throws: PIAMultipleErrors if all endpoints fail, or PIAAccountError if only one endpoint
    func executeWithFailover<T: Decodable & Sendable>(
        path: APIPath,
        method: RequestBuilder.HTTPMethod,
        bodyType: RequestBuilder.BodyType? = nil,
        headers: [String: String] = [:],
        queryParameters: [String: String]? = nil,
        decoder: JSONDecoder = .piaCodable
    ) async throws -> T {
        let endpoints = endpointProvider.accountEndpoints()
        var errors: [PIAAccountError] = []

        for endpoint in endpoints {
            do {
                // Create HTTP client for this endpoint
                let client = createClient(for: endpoint)

                // Build URL for this endpoint
                let url = try URLBuilder.buildURL(
                    ipOrRootDomain: endpoint.ipOrRootDomain,
                    path: path,
                    queryParameters: queryParameters
                )

                // Build request
                let request = RequestBuilder.build(
                    url: url,
                    method: method,
                    bodyType: bodyType,
                    headers: headers
                )

                // Execute request
                return try await client.execute(request: request, decoder: decoder)

            } catch let error as PIAAccountError {
                errors.append(error)
                continue  // Try next endpoint
            } catch {
                errors.append(PIAAccountError.networkFailure(error))
                continue
            }
        }

        // All endpoints failed
        if errors.count == 1, let singleError = errors.first {
            throw singleError
        } else {
            throw PIAMultipleErrors(errors: errors)
        }
    }

    /// Executes a request without expecting a response body
    /// - Parameters:
    ///   - path: The API path
    ///   - method: HTTP method
    ///   - bodyType: Request body type (JSON or form-encoded)
    ///   - headers: Additional HTTP headers
    /// - Throws: PIAMultipleErrors if all endpoints fail, or PIAAccountError if only one endpoint
    func executeVoidWithFailover(
        path: APIPath,
        method: RequestBuilder.HTTPMethod,
        bodyType: RequestBuilder.BodyType? = nil,
        headers: [String: String] = [:],
        queryParameters: [String: String]? = nil
    ) async throws {
        let endpoints = endpointProvider.accountEndpoints()
        var errors: [PIAAccountError] = []

        for endpoint in endpoints {
            do {
                // Create HTTP client for this endpoint
                let client = createClient(for: endpoint)

                // Build URL for this endpoint
                let url = try URLBuilder.buildURL(
                    ipOrRootDomain: endpoint.ipOrRootDomain,
                    path: path,
                    queryParameters: queryParameters
                )

                // Build request
                let request = RequestBuilder.build(
                    url: url,
                    method: method,
                    bodyType: bodyType,
                    headers: headers
                )

                // Execute request
                try await client.executeVoid(request: request)
                return  // Success

            } catch let error as PIAAccountError {
                errors.append(error)
                continue  // Try next endpoint
            } catch {
                errors.append(PIAAccountError.networkFailure(error))
                continue
            }
        }

        // All endpoints failed
        if errors.count == 1, let singleError = errors.first {
            throw singleError
        } else {
            throw PIAMultipleErrors(errors: errors)
        }
    }

    // MARK: - Private Helpers

    private func createClient(for endpoint: PIAAccountEndpoint) -> AccountHTTPClient {
        let cert = endpoint.usePinnedCertificate ? certificate : nil
        let hostname = endpoint.usePinnedCertificate ? endpoint.ipOrRootDomain : nil
        let commonName = endpoint.certificateCommonName

        return AccountHTTPClient(
            certificate: cert,
            hostname: hostname,
            commonName: commonName,
            userAgent: userAgent
        )
    }
}
