
import Foundation
import NWHttpConnection
@testable import PIALibrary


struct NetworkRequestConfigurationMock: NetworkRequestConfigurationType {
    
    var networkRequestModule: NetworkRequestModule = .account
    var path: RequestAPI.Path = .vpnToken
    var httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .get
    var inlcudeAuthHeaders: Bool = true
    var contentType: NetworkRequestContentType = .json
    var urlQueryParameters: [String : String]? = nil
    var responseDataType: NWHttpConnection.NWDataResponseType = .jsonData
    var body: Data? = nil
    var otherHeaders: [String : String]? = nil
    var timeout: TimeInterval = 1
    var requestQueue: DispatchQueue? = nil
    
}
