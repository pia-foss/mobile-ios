
import Foundation
@testable import PIALibrary

struct NetworkRequestResponseStub: NetworkRequestResponseType {
    let statusCode: Int? = 200
    let data: Data?
    
    init(data: Data?) {
        self.data = data
    }
}
