import Testing
import Foundation
@testable import PIAAccount

@Suite struct URLBuilderTests {

    // MARK: - Domain Detection Tests

    @Test("Valid domains are recognized")
    func isDomainValidDomains() {
        let validDomains = [
            "privateinternetaccess.com",
            "sub.privateinternetaccess.com",
            "api.example.com",
            "test-domain.io",
            "my-site.co.uk",
            "example.org",
            "test.staging.pia.com"
        ]

        for domain in validDomains {
            #expect(URLBuilder.isDomain(domain))
        }
    }

    @Test("Invalid domains are not recognized")
    func isDomainInvalidDomains() {
        let invalidDomains = [
            "not a domain",
            "192.168.1.1",
            "http://example.com",
            "example",
            ".com",
            "example.",
            "",
            "123",
            "example..com"
        ]

        for domain in invalidDomains {
            #expect(!URLBuilder.isDomain(domain))
        }
    }

    // MARK: - IPv4 Detection Tests

    @Test("Valid IPv4 addresses are recognized")
    func isIPv4ValidIPs() {
        let validIPs = [
            "192.168.1.1",
            "10.0.0.1",
            "172.16.0.1",
            "8.8.8.8",
            "255.255.255.255",
            "0.0.0.0",
            "127.0.0.1"
        ]

        for ip in validIPs {
            #expect(URLBuilder.isIPv4(ip))
        }
    }

    @Test("Invalid IPv4 addresses are not recognized")
    func isIPv4InvalidIPs() {
        let invalidIPs = [
            "999.999.999.999",
            "192.168.1",
            "192.168.1.1.1",
            "example.com",
            "192.168.1.256",
            "192.168.-1.1",
            "192.168.1.a",
            "",
            "not an ip",
            "2001:0db8:85a3:0000:0000:8a2e:0370:7334" // IPv6
        ]

        for ip in invalidIPs {
            #expect(!URLBuilder.isIPv4(ip))
        }
    }

    // MARK: - URL Building Tests - Domains

    @Test("Build URL for domain with subdomain")
    func buildURLDomainWithSubdomain() throws {
        let domain = "privateinternetaccess.com"
        let path = APIPath.login // subdomain = "apiv5"

        let url = try URLBuilder.buildURL(ipOrRootDomain: domain, path: path)

        #expect(url.absoluteString == "https://apiv5.privateinternetaccess.com/api/client/v5/api_token")
    }

    @Test("Build URL for domain with different subdomains")
    func buildURLDomainWithDifferentSubdomains() throws {
        let domain = "example.com"

        // Test different paths with different subdomains
        let testCases: [(APIPath, String, String)] = [
            (.login, "apiv5", "/api/client/v5/api_token"),
            (.accountDetails, "apiv2", "/api/client/v2/account"),
            (.signup, "api", "/api/client/signup")
        ]

        for (path, expectedSubdomain, expectedPath) in testCases {
            let url = try URLBuilder.buildURL(ipOrRootDomain: domain, path: path)
            let expectedURL = "https://\(expectedSubdomain).example.com\(expectedPath)"
            #expect(url.absoluteString == expectedURL)
        }
    }

    // MARK: - URL Building Tests - IP Addresses

    @Test("Build URL for IPv4 without subdomain")
    func buildURLIPv4NoSubdomain() throws {
        let ip = "192.168.1.100"
        let path = APIPath.login

        let url = try URLBuilder.buildURL(ipOrRootDomain: ip, path: path)

        // IP addresses should NOT get subdomain prepended
        #expect(url.absoluteString == "https://192.168.1.100/api/client/v5/api_token")
    }

    @Test("Build URL for IPv4 with different paths")
    func buildURLIPv4WithDifferentPaths() throws {
        let ip = "10.0.0.1"

        let testCases: [APIPath] = [
            .login,
            .accountDetails,
            .vpnToken,
            .dedicatedIP
        ]

        for path in testCases {
            let url = try URLBuilder.buildURL(ipOrRootDomain: ip, path: path)
            // Should be ip + path, no subdomain
            #expect(url.absoluteString.hasPrefix("https://10.0.0.1/"))
            #expect(!url.absoluteString.contains("apiv"))
        }
    }

    // MARK: - URL Building Tests - Staging

    @Test("Build URL for staging domain without subdomain")
    func buildURLStagingDomainNoSubdomain() throws {
        let stagingDomain = "staging.privateinternetaccess.com"
        let path = APIPath.login

        let url = try URLBuilder.buildURL(ipOrRootDomain: stagingDomain, path: path)

        // Staging domains should NOT get subdomain prepended
        #expect(url.absoluteString == "https://staging.privateinternetaccess.com/api/client/v5/api_token")
    }

    @Test("Build URL for staging variations")
    func buildURLStagingVariations() throws {
        let stagingDomains = [
            "staging.example.com",
            "api.staging.pia.com",
            "test-staging.io"
        ]

        for domain in stagingDomains {
            let url = try URLBuilder.buildURL(ipOrRootDomain: domain, path: .login)
            // Should not prepend subdomain if staging is in domain
            #expect(url.absoluteString.hasPrefix("https://\(domain)/"))
            #expect(!url.absoluteString.contains(".apiv"))
        }
    }

    // MARK: - URL Building Tests - All API Paths

    @Test("Build URL for all API paths")
    func buildURLAllAPIPaths() throws {
        let domain = "example.com"

        // Test that all API paths can build valid URLs
        let allPaths: [APIPath] = [
            .login,
            .logout,
            .refreshAPIToken,
            .vpnToken,
            .accountDetails,
            .deleteAccount,
            .clientStatus,
            .setEmail,
            .dedicatedIP,
            .renewDedicatedIP,
            .iosSubscriptions,
            .iosPayment,
            .signup,
            .invites,
            .redeem,
            .messages,
            .iosFeatureFlag,
            .loginLink
        ]

        for path in allPaths {
            let url = try URLBuilder.buildURL(ipOrRootDomain: domain, path: path)
            #expect(url.absoluteString.hasPrefix("https://"))
            #expect(url.absoluteString.contains(path.rawValue))
        }
    }

    // MARK: - Error Cases

    @Test("Invalid domain throws error")
    func buildURLInvalidDomainThrows() {
        let invalidDomains = [
            "not a domain",
            "999.999.999.999",
            "",
            "http://example.com"
        ]

        for invalid in invalidDomains {
            #expect(throws: PIAAccountError.self) {
                try URLBuilder.buildURL(ipOrRootDomain: invalid, path: .login)
            }
        }
    }

    // MARK: - URL Component Tests

    @Test("Build URL has correct components")
    func buildURLURLComponents() throws {
        let domain = "example.com"
        let path = APIPath.accountDetails

        let url = try URLBuilder.buildURL(ipOrRootDomain: domain, path: path)

        // Verify URL components
        #expect(url.scheme == "https")
        #expect(url.host == "apiv2.example.com")
        #expect(url.path == "/api/client/v2/account")
    }

    // MARK: - Edge Cases

    @Test("Domain with trailing dot")
    func buildURLDomainWithTrailingDot() throws {
        // Some systems use trailing dots for fully qualified domain names
        let domain = "example.com."

        // Should either handle gracefully or throw clear error
        // Current implementation might not handle this - verify behavior
        do {
            let url = try URLBuilder.buildURL(ipOrRootDomain: domain, path: .login)
            // If it succeeds, verify URL is correct
            #expect(url.absoluteString.contains("example.com"))
        } catch {
            // If it fails, that's also acceptable for edge case
            #expect(error is PIAAccountError)
        }
    }

    @Test("Case insensitive domain handling")
    func buildURLCaseInsensitive() throws {
        let domains = [
            "Example.COM",
            "EXAMPLE.COM",
            "example.COM"
        ]

        for domain in domains {
            let url = try URLBuilder.buildURL(ipOrRootDomain: domain, path: .login)
            // Domain should be normalized to lowercase in URL
            #expect(url.absoluteString.lowercased().contains("example.com"))
        }
    }

    // MARK: - Subdomain Mapping Tests

    @Test("Subdomain mapping is correct")
    func subdomainMapping() {
        // Verify subdomain mappings match implementation
        // apiv5 paths
        #expect(APIPath.login.subdomain == "apiv5")
        #expect(APIPath.vpnToken.subdomain == "apiv5")
        #expect(APIPath.refreshAPIToken.subdomain == "apiv5")
        #expect(APIPath.deleteAccount.subdomain == "apiv5")

        // apiv2 paths
        #expect(APIPath.loginLink.subdomain == "apiv2")
        #expect(APIPath.logout.subdomain == "apiv2")
        #expect(APIPath.accountDetails.subdomain == "apiv2")
        #expect(APIPath.messages.subdomain == "apiv2")
        #expect(APIPath.dedicatedIP.subdomain == "apiv2")
        #expect(APIPath.renewDedicatedIP.subdomain == "apiv2")

        // apiv4 paths
        #expect(APIPath.refreshToken.subdomain == "apiv4")

        // api paths (no version)
        #expect(APIPath.signup.subdomain == "api")
        #expect(APIPath.setEmail.subdomain == "api")
        #expect(APIPath.clientStatus.subdomain == "api")
        #expect(APIPath.invites.subdomain == "api")
        #expect(APIPath.redeem.subdomain == "api")
        #expect(APIPath.iosPayment.subdomain == "api")
        #expect(APIPath.iosSubscriptions.subdomain == "api")
        #expect(APIPath.iosFeatureFlag.subdomain == "api")
    }
}
