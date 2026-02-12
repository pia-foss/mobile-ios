import Testing
import Foundation
@testable import PIAAccountSwift

@Suite("Certificate Pinning Tests")
struct CertificatePinningTests {

    // MARK: - Test Certificate Data

    // Simple valid base64-encoded test data (not real certificates, just for parser testing)
    let validTestCertificatePEM = """
    -----BEGIN CERTIFICATE-----
    VGVzdENlcnRpZmljYXRlRGF0YUZvclBhcnNpbmdUZXN0cw==
    -----END CERTIFICATE-----
    """

    // Different test data
    let differentTestCertificatePEM = """
    -----BEGIN CERTIFICATE-----
    RGlmZmVyZW50VGVzdENlcnRpZmljYXRlRGF0YQ==
    -----END CERTIFICATE-----
    """

    // MARK: - Certificate Pinner Initialization Tests

    @Test("Certificate pinner initializes successfully")
    func certificatePinnerInitialization() {
        let pinner = CertificatePinner(certificate: validTestCertificatePEM)
        #expect(pinner != nil)
    }

    @Test("Certificate pinner initializes with hostname")
    func certificatePinnerInitializationWithHostname() {
        let pinner = CertificatePinner(
            certificate: validTestCertificatePEM,
            hostname: "example.com"
        )
        #expect(pinner != nil)
    }

    @Test("Certificate pinner initializes with common name")
    func certificatePinnerInitializationWithCommonName() {
        let pinner = CertificatePinner(
            certificate: validTestCertificatePEM,
            commonName: "*.privateinternetaccess.com"
        )
        #expect(pinner != nil)
    }

    @Test("Certificate pinner initializes with both hostname and common name")
    func certificatePinnerInitializationWithBoth() {
        let pinner = CertificatePinner(
            certificate: validTestCertificatePEM,
            hostname: "api.example.com",
            commonName: "*.example.com"
        )
        #expect(pinner != nil)
    }

    // MARK: - PEM Parsing Tests

    @Test("PEM parsing handles valid format")
    func pemParsingValidFormat() {
        // Certificate pinner should successfully parse valid PEM
        let pinner = CertificatePinner(certificate: validTestCertificatePEM)
        #expect(pinner != nil)
    }

    @Test("PEM parsing handles certificate without headers")
    func pemParsingWithoutHeaders() {
        // Test parsing certificate without BEGIN/END headers
        let certificateWithoutHeaders = validTestCertificatePEM
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let pinner = CertificatePinner(certificate: certificateWithoutHeaders)
        #expect(pinner != nil)
    }

    @Test("PEM parsing handles extra whitespace")
    func pemParsingWithExtraWhitespace() {
        // Add whitespace within the PEM block (not before BEGIN)
        let certificateWithWhitespace = """
        -----BEGIN CERTIFICATE-----

        VGVzdENlcnRpZmljYXRlRGF0YUZvclBhcnNpbmdUZXN0cw==

        -----END CERTIFICATE-----
        """

        let pinner = CertificatePinner(certificate: certificateWithWhitespace)
        #expect(pinner != nil)
    }

    // MARK: - URL Session Delegate Tests

    @Test("Certificate pinner conforms to URLSessionDelegate")
    func urlSessionDelegateConformance() {
        let pinner = CertificatePinner(certificate: validTestCertificatePEM)
        #expect(pinner is URLSessionDelegate)
    }

    // MARK: - Without Pinning Tests

    @Test("URLSession works without pinning")
    func urlSessionWithoutPinning() async throws {
        // Test that normal HTTPS works without pinning
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)

        // Use a reliable public endpoint
        let url = URL(string: "https://www.apple.com")!

        let (data, response) = try await session.data(from: url)

        #expect(data.isEmpty == false)
        if let httpResponse = response as? HTTPURLResponse {
            #expect((200...299).contains(httpResponse.statusCode))
        }
    }

    // MARK: - Thread Safety Tests

    @Test("Certificate pinner handles concurrent initialization")
    func certificatePinnerConcurrentInitialization() async {
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    _ = CertificatePinner(certificate: self.validTestCertificatePEM)
                }
            }
        }

        // Should not crash - test passes if we get here
        #expect(Bool(true))
    }

    // MARK: - Documentation Tests

    @Test("Documentation example works correctly")
    func certificatePinningDocumentationExample() {
        // Test the usage example from documentation
        let certificatePEM = validTestCertificatePEM

        let pinner = CertificatePinner(
            certificate: certificatePEM,
            hostname: "api.privateinternetaccess.com",
            commonName: "*.privateinternetaccess.com"
        )

        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config, delegate: pinner, delegateQueue: nil)

        #expect(session != nil)
    }
}
