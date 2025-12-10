

import Foundation
import NWHttpConnection

struct AccountDetailsRequestConfiguration: NetworkRequestConfigurationType {
    
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .accountDetails
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .get
    let contentType: NetworkRequestContentType = .json
    let inlcudeAuthHeaders: Bool = true
    let urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    var otherHeaders: [String : String]? = nil
    var body: Data? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "accountDetails_request.queue")
}


