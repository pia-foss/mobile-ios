
import Foundation
@testable import PIA_VPN_tvOS

class ServerMock: ServerType {
    var name: String
    
    var identifier: String
    
    var regionIdentifier: String
    
    var country: String
    
    var geo: Bool
    
    init(name: String, identifier: String, regionIdentifier: String, country: String, geo: Bool) {
        self.name = name
        self.identifier = identifier
        self.regionIdentifier = regionIdentifier
        self.country = country
        self.geo = geo
    }
    
    convenience init() {
        self.init(name: "mock-server-name", identifier: "mock-server-id", regionIdentifier: "mock-server-region-id", country: "mock-country", geo: false)
    }
    
    
}
