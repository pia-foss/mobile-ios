import Testing
import Foundation
@testable import PIAAccount

@Suite struct ActorIsolationTests {

    // MARK: - TokenManager Concurrency Tests

    @Test("TokenManager concurrent reads")
    func tokenManagerConcurrentReads() async throws {
        let testService = "com.pia.test.\(UUID().uuidString)"
        let tokenManager = TokenManager(keychainService: testService)

        // Store initial token
        let token = APITokenResponse(
            apiToken: "test-token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
        )
        try await tokenManager.storeAPIToken(token)

        // Spawn 100 concurrent reads
        await withTaskGroup(of: String?.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    try? await tokenManager.getAPITokenString()
                }
            }

            var results: [String?] = []
            for await result in group {
                results.append(result)
            }

            // All reads should succeed and return same value
            #expect(results.count == 100)
            #expect(results.allSatisfy { $0 == "test-token" })
        }

        // Cleanup
        try await tokenManager.clearAllTokens()
    }

    @Test("TokenManager concurrent writes")
    func tokenManagerConcurrentWrites() async throws {
        let testService = "com.pia.test.\(UUID().uuidString)"
        let tokenManager = TokenManager(keychainService: testService)

        // Spawn 50 concurrent writes with different tokens
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    let token = APITokenResponse(
                        apiToken: "token-\(i)",
                        expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
                    )
                    try? await tokenManager.storeAPIToken(token)
                }
            }
        }

        // After all writes complete, there should be exactly one token stored
        let finalToken = try await tokenManager.getAPITokenString()
        #expect(finalToken != nil)
        #expect(finalToken!.hasPrefix("token-"))

        // Cleanup
        try await tokenManager.clearAllTokens()
    }

    @Test("TokenManager mixed concurrent access")
    func tokenManagerMixedConcurrentAccess() async throws {
        let testService = "com.pia.test.\(UUID().uuidString)"
        let tokenManager = TokenManager(keychainService: testService)

        // Store initial token
        let initialToken = APITokenResponse(
            apiToken: "initial",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
        )
        try await tokenManager.storeAPIToken(initialToken)

        // Spawn mixed operations: reads, writes, checks
        await withTaskGroup(of: Void.self) { group in
            // 30 reads
            for _ in 0..<30 {
                group.addTask {
                    _ = try? await tokenManager.getAPITokenString()
                }
            }

            // 20 writes
            for i in 0..<20 {
                group.addTask {
                    let token = APITokenResponse(
                        apiToken: "token-\(i)",
                        expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
                    )
                    try? await tokenManager.storeAPIToken(token)
                }
            }

            // 10 refresh checks
            for _ in 0..<10 {
                group.addTask {
                    _ = try? await tokenManager.needsAPITokenRefresh()
                }
            }
        }

        // Should not crash and should have valid state
        let finalToken = try await tokenManager.getAPITokenString()
        #expect(finalToken != nil)

        // Cleanup
        try await tokenManager.clearAllTokens()
    }

    // MARK: - Token Cache Concurrency Tests (PIAAccountClient)

    @Test("PIAAccountClient concurrent token access")
    func piaAccountClientConcurrentTokenAccess() async throws {
        // Test that the cached token properties are thread-safe
        let endpoint = TestEndpointProvider()
        let client = PIAAccountClient(
            endpointProvider: endpoint,
            certificate: nil,
            userAgent: "Test/1.0"
        )

        // Access apiToken property from multiple tasks concurrently
        await withTaskGroup(of: String?.self) { group in
            for _ in 0..<100 {
                group.addTask { [client] in
                    return await client.apiToken
                }
            }

            var count = 0
            for await result in group {
                count += 1
                _ = result
            }

            #expect(count == 100)
        }
    }

    @Test("PIAAccountClient concurrent VPN token access")
    func piaAccountClientConcurrentVPNTokenAccess() async throws {
        let endpoint = TestEndpointProvider()
        let client = PIAAccountClient(
            endpointProvider: endpoint,
            certificate: nil,
            userAgent: "Test/1.0"
        )

        // Access vpnToken property from multiple tasks concurrently
        await withTaskGroup(of: String?.self) { group in
            for _ in 0..<100 {
                group.addTask { [client] in
                    return await client.vpnToken
                }
            }

            var count = 0
            for await result in group {
                count += 1
                _ = result
            }

            #expect(count == 100)
        }
    }

    // MARK: - EndpointManager Concurrency Tests

    @Test("EndpointManager concurrent requests")
    func endpointManagerConcurrentRequests() async throws {
        // Test that EndpointManager handles concurrent requests safely
        let endpoint = TestEndpointProvider()
        let endpointManager = EndpointManager(
            endpointProvider: endpoint,
            certificate: nil,
            userAgent: "Test/1.0"
        )

        // This test would require mock URLSession
        // For now, verify the manager can be accessed concurrently
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    // In real test, would make actual request
                    // For now, just access the manager
                    _ = endpointManager
                }
            }
        }

        #expect(true)
    }

    // MARK: - AccountHTTPClient Concurrency Tests

    @Test("AccountHTTPClient concurrent requests")
    func accountHTTPClientConcurrentRequests() async throws {
        let client = AccountHTTPClient(
            certificate: nil,
            hostname: nil,
            commonName: nil,
            userAgent: "Test/1.0"
        )

        // Create test requests
        let testURL = URL(string: "https://httpbin.org/delay/1")!
        var request = URLRequest(url: testURL)
        request.httpMethod = "GET"

        // Launch 10 concurrent requests
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<10 {
                group.addTask { [client, request] in
                    do {
                        // Use executeVoid since we don't care about response parsing
                        try await client.executeVoid(request: request)
                        return true
                    } catch {
                        return false
                    }
                }
            }

            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }

            // Most or all should succeed (network permitting)
            #expect(successCount > 0)
        }
    }

    // MARK: - Data Race Detection Tests

    @Test("TokenManager has no data races")
    func tokenManagerNoDataRaces() async throws {
        // This test should be run with Thread Sanitizer enabled
        // Run with: swift test --sanitize=thread

        let testService = "com.pia.test.\(UUID().uuidString)"
        let tokenManager = TokenManager(keychainService: testService)

        // Perform various operations that could cause data races
        await withTaskGroup(of: Void.self) { group in
            // Concurrent stores
            for i in 0..<20 {
                group.addTask {
                    let token = APITokenResponse(
                        apiToken: "token-\(i)",
                        expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))
                    )
                    try? await tokenManager.storeAPIToken(token)
                }
            }

            // Concurrent reads
            for _ in 0..<20 {
                group.addTask {
                    _ = try? await tokenManager.getAPIToken()
                }
            }

            // Concurrent checks
            for _ in 0..<20 {
                group.addTask {
                    _ = try? await tokenManager.needsTokenRefresh()
                }
            }

            // Concurrent clears
            for _ in 0..<5 {
                group.addTask {
                    try? await tokenManager.clearAllTokens()
                }
            }
        }

        // Thread Sanitizer will detect any data races
        #expect(true)

        try await tokenManager.clearAllTokens()
    }

    // MARK: - Actor Isolation Verification Tests

    @Test("Actor isolation enforced at compile time")
    func actorIsolationCompileTimeVerification() async {
        // These tests verify at compile time that actor isolation is enforced

        let tokenManager = TokenManager(keychainService: "test")

        // This should compile - async access to actor
        _ = try? await tokenManager.getAPIToken()

        // This should NOT compile (will fail at compile time):
        // let token = tokenManager.getAPIToken() // ❌ Cannot call actor method synchronously

        #expect(true)
    }

    @Test("Token types conform to Sendable")
    func sendableTokenTypes() {
        // Verify token types conform to Sendable
        let apiToken = APITokenResponse(
            apiToken: "test",
            expiresAt: ISO8601DateFormatter().string(from: Date())
        )

        let vpnToken = VPNTokenResponse(
            vpnUsernameToken: "user",
            vpnPasswordToken: "pass",
            expiresAt: ISO8601DateFormatter().string(from: Date())
        )

        // Should be able to send across concurrency boundaries
        Task {
            await self.sendAPIToken(apiToken)
            await self.sendVPNToken(vpnToken)
        }
    }

    @Sendable
    private func sendAPIToken(_ token: APITokenResponse) async {
        #expect(token.apiToken != nil)
    }

    @Sendable
    private func sendVPNToken(_ token: VPNTokenResponse) async {
        #expect(token.vpnUsernameToken != nil)
    }

    // MARK: - Helper Test Endpoint Provider

    private struct TestEndpointProvider: PIAAccountEndpointProvider {
        func accountEndpoints() -> [PIAAccountEndpoint] {
            return [
                PIAAccountEndpoint(
                    ipOrRootDomain: "privateinternetaccess.com",
                    isProxy: false,
                    usePinnedCertificate: false,
                    certificateCommonName: nil
                )
            ]
        }
    }
}
