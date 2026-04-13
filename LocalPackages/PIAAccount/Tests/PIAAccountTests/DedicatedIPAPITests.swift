import Testing
import Foundation
@testable import PIAAccount

@Suite struct DedicatedIPAPITests {

    // MARK: - Model Decoding Tests

    @Test("DipCountriesResponse decodes from JSON")
    func dipCountriesDecoding() throws {
        let json = """
        {"dedicatedIpCountriesAvailable": [
            {"country_code": "US", "name": "United States",
             "new_regions": ["NY"], "regions": ["NY", "LA"]}
        ]}
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder.piaCodable.decode(DipCountriesResponse.self, from: data)
        #expect(response.dedicatedIpCountriesAvailable.count == 1)
        #expect(response.dedicatedIpCountriesAvailable[0].countryCode == "US")
        #expect(response.dedicatedIpCountriesAvailable[0].name == "United States")
        #expect(response.dedicatedIpCountriesAvailable[0].newRegions == ["NY"])
        #expect(response.dedicatedIpCountriesAvailable[0].regions.count == 2)
    }

    @Test("DedicatedIPTokenDetails decodes from JSON")
    func tokenDetailsDecoding() throws {
        let json = """
        {"meta_data": [{"common_name": "us-ny-001", "region_id": "us_ny"}],
         "partners_id": 123, "redeemed_at": "2026-02-12T10:30:00Z", "token": "abc123"}
        """
        let data = json.data(using: .utf8)!
        let details = try JSONDecoder.piaCodable.decode(DedicatedIPTokenDetails.self, from: data)
        #expect(details.token == "abc123")
        #expect(details.partnersId == 123)
        #expect(details.redeemedAt == "2026-02-12T10:30:00Z")
        #expect(details.metaData.count == 1)
        #expect(details.metaData[0].commonName == "us-ny-001")
        #expect(details.metaData[0].regionId == "us_ny")
    }

    @Test("VpnSignUpInformation decodes from JSON")
    func vpnSignupDecoding() throws {
        let json = """
        {"username": "p1234567", "password": "abc123"}
        """
        let data = json.data(using: .utf8)!
        let info = try JSONDecoder.piaCodable.decode(VpnSignUpInformation.self, from: data)
        #expect(info.username == "p1234567")
        #expect(info.password == "abc123")
    }

    @Test("GetDedicatedIPTokenRequest encodes to JSON correctly")
    func getDedicatedIPTokenRequestEncoding() throws {
        let request = GetDedicatedIPTokenRequest(countryCode: "GB", region: "London")
        let data = try JSONEncoder.piaCodable.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: String]
        #expect(json["country_code"] == "GB")
        #expect(json["region"] == "London")
    }

    // MARK: - API Path Tests

    @Test("New DIP endpoints have correct paths")
    func dipEndpointPaths() {
        #expect(APIPath.supportedDedicatedIPCountries.rawValue == "/api/client/v5/dip_regions")
        #expect(APIPath.getDedicatedIP.rawValue == "/api/client/v5/redeem_dip_token")
    }

    @Test("New DIP endpoints use apiv5 subdomain")
    func dipEndpointSubdomains() {
        #expect(APIPath.supportedDedicatedIPCountries.subdomain == "apiv5")
        #expect(APIPath.getDedicatedIP.subdomain == "apiv5")
    }
}
