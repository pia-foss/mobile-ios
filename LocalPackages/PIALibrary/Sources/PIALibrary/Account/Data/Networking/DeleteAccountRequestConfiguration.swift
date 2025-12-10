

import Foundation
import NWHttpConnection

struct DeleteAccountRequestConfiguration: NetworkRequestConfigurationType {
    
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .deleteAccount
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .delete
    let contentType: NetworkRequestContentType = .json
    let inlcudeAuthHeaders: Bool = true
    let urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    var otherHeaders: [String : String]? = nil
    var body: Data? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "deleteAccount_request.queue")
}



