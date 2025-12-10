
import Foundation
import XCTest
@testable import PIALibrary

class AuthTokenSerializerTests: XCTestCase {
    
    class Fixture {
        let validApiTokenJsonString = "{\"api_token\":\"some_api_token\",\"expires_at\":\"2034-08-11T00:00:00Z\"}"
        let expiredApiTokenJsonString = "{\"api_token\":\"some_api_token\",\"expires_at\":\"2023-08-11T00:00:00Z\"}"
        let validVpnTokenJsonString = "{\"vpn_secret1\":\"vpn_token_username\",\"vpn_secret2\":\"vpn_token_password\",\"expires_at\":\"2034-08-08T00:00:00Z\"}"
        let expiredVpnTokenJsonString = "{\"vpn_secret1\":\"vpn_token_username\",\"vpn_secret2\":\"vpn_token_password\",\"expires_at\":\"2023-06-08T00:00:00Z\"}"
        
        let apiToken = APIToken(apiToken: "other_api_token", expiresAt: Date.init(timeIntervalSinceNow: 1000))
        
        let vpnToken = VpnToken(vpnUsernameToken: "other_vpn_token_username", vpnPasswordToken: "other_vpn_token_password", expiresAt: Date.init(timeIntervalSinceNow: 1000))
        
    }

    var sut: AuthTokenSerializer!
    var fixture: Fixture!
    
    override func setUp() {
        fixture = Fixture()
        sut = AuthTokenSerializer()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    

    func testDecodeValidAPIToken() {
        // GIVEN some valid api token Data
        let apiTokenData = fixture.validApiTokenJsonString.data(using: .utf8)!
        
        // WHEN decoding the Data
        let decodedAPIToken = sut.decodeAPIToken(from: apiTokenData)!

        // THEN the decoded api value is 'some_api_token'
        XCTAssertEqual(decodedAPIToken.apiToken, "some_api_token")
        // AND the decoded API token is NOT expired
        XCTAssertFalse(decodedAPIToken.isExpired)
    }
    
    func testDecodeExpiredAPIToken() {
        // GIVEN an expired api token Data
        let apiTokenData = fixture.expiredApiTokenJsonString.data(using: .utf8)!
        
        // WHEN decoding the Data
        let decodedAPIToken = sut.decodeAPIToken(from: apiTokenData)!

        
        // THEN the decoded api value is 'some_api_token'
        XCTAssertEqual(decodedAPIToken.apiToken, "some_api_token")
        // AND the decoded API token is expired
        XCTAssertTrue(decodedAPIToken.isExpired)
    
    }
    
    func testDecodeValidVpnToken() {
        // GIVEN some valid vpn token Data
        let tokenData = fixture.validVpnTokenJsonString.data(using: .utf8)!
        
        // WHEN decoding the Data
        let decodedVpnToken = sut.decodeVpnToken(from: tokenData)!

        // THEN the decoded values are
        XCTAssertEqual(decodedVpnToken.vpnUsernameToken, "vpn_token_username")
        XCTAssertEqual(decodedVpnToken.vpnPasswordToken, "vpn_token_password")
        // AND the decoded token is NOT expired
        XCTAssertFalse(decodedVpnToken.isExpired)
    }
    
    func testDecodeExpiredVpnToken() {
        // GIVEN an expired vpn token Data
        let tokenData = fixture.expiredVpnTokenJsonString.data(using: .utf8)!
        
        // WHEN decoding the Data
        let decodedVpnToken = sut.decodeVpnToken(from: tokenData)!

        // THEN the decoded values are
        XCTAssertEqual(decodedVpnToken.vpnUsernameToken, "vpn_token_username")
        XCTAssertEqual(decodedVpnToken.vpnPasswordToken, "vpn_token_password")
        // AND the decoded token is expired
        XCTAssertTrue(decodedVpnToken.isExpired)
    
    }
    
    func testEncodeVpnToken() {
        // WHEN encoding a valid Vpn Token into a JSON string
        let encodedTokenString = sut.encode(vpnToken: fixture.vpnToken)
        
        let expirationDate = fixture.vpnToken.expiresAt
        let dateFormatter = ISO8601DateFormatter()
        let expirationDateString = dateFormatter.string(from: expirationDate)
        
        let expirationJsonEntry = "\"expires_at\":\"\(expirationDateString)\""
        let usernameJsonEntry = "\"vpn_secret1\":\"other_vpn_token_username\""
        let passwordJsonEntry = "\"vpn_secret2\":\"other_vpn_token_password\""
        
        // THEN the JSON strng contains the following entries
        XCTAssertTrue(encodedTokenString!.contains(expirationJsonEntry))
        XCTAssertTrue(encodedTokenString!.contains(usernameJsonEntry))
        XCTAssertTrue(encodedTokenString!.contains(passwordJsonEntry))

    }
    
    func testEncodeApiToken() {
        // WHEN encoding a valid Api Token into a JSON string
        let encodedTokenString = sut.encode(apiToken: fixture.apiToken)
        
        let expirationDate = fixture.apiToken.expiresAt
        let dateFormatter = ISO8601DateFormatter()
        let expirationDateString = dateFormatter.string(from: expirationDate)
        
        let expirationJsonEntry = "\"expires_at\":\"\(expirationDateString)\""
        let apiTokenJsonEntry = "\"api_token\":\"other_api_token\""
        
        // THEN the JSON strng contains the following entries
        XCTAssertTrue(encodedTokenString!.contains(expirationJsonEntry))
        XCTAssertTrue(encodedTokenString!.contains(apiTokenJsonEntry))


    }
    
}
