import Foundation
import Testing

@testable import PIAAccount

@Suite struct LoginQRAPITests {

    @Test("BindLoginTokenRequest encodes the token as login_token")
    func bindLoginTokenRequestEncoding() throws {
        let request = BindLoginTokenRequest(loginToken: "qr-token")
        let data = try JSONEncoder.piaCodable.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: String]
        #expect(json == ["login_token": "qr-token"])
    }

    @Test("Bind login token endpoint has the correct path")
    func bindLoginTokenPath() {
        #expect(APIPath.bindLoginToken.rawValue == "/api/client/v5/login_token/bind")
    }

    @Test("Bind login token endpoint uses the apiv5 subdomain")
    func bindLoginTokenSubdomain() {
        #expect(APIPath.bindLoginToken.subdomain == "apiv5")
    }
}
