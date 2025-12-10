
import Foundation
import NWHttpConnection

struct SignupRequestConfiguration: NetworkRequestConfigurationType {
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .signup
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .post
    let inlcudeAuthHeaders: Bool = false
    
    // Refreshing the auth tokens is not needed before executing the refresh API token request
    let refreshAuthTokensIfNeeded: Bool = false
    var contentType: NetworkRequestContentType = .json
    let urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    var body: Data? = nil
    var otherHeaders: [String : String]? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "signup.queue")
}
