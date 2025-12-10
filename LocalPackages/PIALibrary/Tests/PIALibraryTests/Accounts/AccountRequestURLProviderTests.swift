
import Foundation

import XCTest
@testable import PIALibrary

class AccountRequestURLProviderTests: XCTestCase {
    class Fixture {
        let ipEndpoint = PinningEndpoint(host: "103.102.10.20", isProxy: false, useCertificatePinning: true, commonName: "server_cn")
        let piaDnsEndpoint = PinningEndpoint(host: "privateinternetaccess.com", isProxy: false, useCertificatePinning: false, commonName: nil)
        let piaProxyEndpoint = PinningEndpoint(host: "piaproxy.net", isProxy: true, useCertificatePinning: false, commonName: nil)
        
    }
    
    var fixture: Fixture!
    var sut: NetworkRequestURLProvider!
    
    override func setUp() {
        fixture = Fixture()
        sut = NetworkRequestURLProvider()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    

    func testRequestURLForIPEndpoint_andRefreshApiTokenPath() {
        // GIVEN that the current endpoint is an IP endpoint
        let currentEndpoint = fixture.ipEndpoint
        
        // WHEN calculating the request URL
        let url = sut.getURL(for: currentEndpoint, path: .refreshApiToken, query: nil)
        
        // THEN the url is not nil
        XCTAssertNotNil(url)
        // AND the resultant URL does not contain a subdomain
        XCTAssertEqual(url!.absoluteString, "https://103.102.10.20/api/client/v5/refresh")
    }
    
    func testRequestURLForPiaDnsEndpoint_andRefreshApiTokenPath() {
        // GIVEN that the current endpoint is PIA dns endpoint
        let currentEndpoint = fixture.piaDnsEndpoint
        
        // WHEN calculating the request URL
        let url = sut.getURL(for: currentEndpoint, path: .refreshApiToken, query: nil)
        
        // THEN the url is not nil
        XCTAssertNotNil(url)
        // AND the resultant URL contains a subdomain
        XCTAssertEqual(url!.absoluteString, "https://apiv5.privateinternetaccess.com/api/client/v5/refresh")
    }
    
    
    func testRequestURLForPiaProxyEndpoint_andRefreshApiTokenPath() {
        // GIVEN that the current endpoint is PIA proxy endpoint
        let currentEndpoint = fixture.piaProxyEndpoint
        
        // WHEN calculating the request URL
        let url = sut.getURL(for: currentEndpoint, path: .refreshApiToken, query: nil)
        
        // THEN the url is not nil
        XCTAssertNotNil(url)
        // AND the resultant URL contains a subdomain
        XCTAssertEqual(url!.absoluteString, "https://apiv5.piaproxy.net/api/client/v5/refresh")
    }
    
    func testRequestURLForIPEndpoint_andRefreshVpnTokenPath() {
        // GIVEN that the current endpoint is an IP endpoint
        let currentEndpoint = fixture.ipEndpoint
        
        // WHEN calculating the request URL
        let url = sut.getURL(for: currentEndpoint, path: .vpnToken, query: nil)
        
        // THEN the url is not nil
        XCTAssertNotNil(url)
        // AND the resultant URL does not contain a subdomain
        XCTAssertEqual(url!.absoluteString, "https://103.102.10.20/api/client/v5/vpn_token")
    }
    
    func testRequestURLForPiaDnsEndpoint_andRefreshVpnTokenPath() {
        // GIVEN that the current endpoint is PIA dns endpoint
        let currentEndpoint = fixture.piaDnsEndpoint
        
        // WHEN calculating the request URL
        let url = sut.getURL(for: currentEndpoint, path: .vpnToken, query: nil)
        
        // THEN the url is not nil
        XCTAssertNotNil(url)
        // AND the resultant URL contains a subdomain
        XCTAssertEqual(url!.absoluteString, "https://apiv5.privateinternetaccess.com/api/client/v5/vpn_token")
    }
    
    
    func testRequestURLForPiaProxyEndpoint_andRefreshVpnTokenPath() {
        // GIVEN that the current endpoint is PIA proxy endpoint
        let currentEndpoint = fixture.piaProxyEndpoint
        
        // WHEN calculating the request URL
        let url = sut.getURL(for: currentEndpoint, path: .vpnToken, query: nil)
        
        // THEN the url is not nil
        XCTAssertNotNil(url)
        // AND the resultant URL contains a subdomain
        XCTAssertEqual(url!.absoluteString, "https://apiv5.piaproxy.net/api/client/v5/vpn_token")
    }
}
