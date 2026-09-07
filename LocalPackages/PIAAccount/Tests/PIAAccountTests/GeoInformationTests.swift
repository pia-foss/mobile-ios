import Foundation
import Testing

@testable import PIAAccount

@Suite struct GeoInformationTests {

    private let payload = Data(
        """
        {
          "request": "173.239.195.251",
          "ip": "173.239.195.251",
          "city_name": "New York",
          "city": "New York",
          "country_name": "United States",
          "country_code2": "US",
          "postal_code": "10118",
          "region_name": "New York",
          "region_code2": "NY",
          "real_region_name": "New York",
          "latitude": 40.7425,
          "longitude": -73.9877,
          "time_zone": "America/New_York",
          "dma_code": 501,
          "isp": "Clouvider Limited",
          "using_pia_server": false
        }
        """.utf8)

    @Test("A geo response maps ip, country_code2 and using_pia_server")
    func decodeGeoResponse() throws {
        let geo = try JSONDecoder.piaCodable.decode(GeoInformation.self, from: payload)

        #expect(geo.ip == "173.239.195.251")
        #expect(geo.countryCode == "US")
        #expect(geo.usingPIAServer == false)
    }

    @Test("A geo response answered through a PIA server reports it")
    func decodeGeoResponseThroughPIAServer() throws {
        let payload = Data(
            """
            {"ip": "138.199.7.1", "country_code2": "NL", "using_pia_server": true}
            """.utf8)

        let geo = try JSONDecoder.piaCodable.decode(GeoInformation.self, from: payload)

        #expect(geo.ip == "138.199.7.1")
        #expect(geo.countryCode == "NL")
        #expect(geo.usingPIAServer == true)
    }

    @Test("A geo response with no geolocation still yields the ip")
    func decodeGeoResponseWithoutCountry() throws {
        let payload = Data(#"{"ip": "173.239.195.251"}"#.utf8)

        let geo = try JSONDecoder.piaCodable.decode(GeoInformation.self, from: payload)

        #expect(geo.ip == "173.239.195.251")
        #expect(geo.countryCode == nil)
        #expect(geo.usingPIAServer == nil)
    }
}
