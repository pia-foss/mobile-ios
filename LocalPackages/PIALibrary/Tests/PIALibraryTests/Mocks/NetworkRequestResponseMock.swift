
import Foundation
import NWHttpConnection
@testable import PIALibrary

struct NetworkRequestResponseMock: NWHttpConnectionDataResponseType, NetworkRequestResponseType {
    var statusCode: Int?
    
    var dataFormat: NWHttpConnection.NWDataResponseType
    
    var data: Data?
    
    init(statusCode: Int? = nil, dataFormat: NWHttpConnection.NWDataResponseType = .jsonData, data: Data? = nil) {
        self.statusCode = statusCode
        self.dataFormat = dataFormat
        self.data = data
    }
    
    
}
