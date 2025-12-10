

import Foundation
@testable import PIALibrary

class ClientStatusDecoderMock: ClientStatusInformationDecoderType {
    
    var decodeClientStatusCalledAttempt = 0
    var decodeClientStatusResult: ClientStatusInformation?
    func decodeClientStatus(from data: Data) -> ClientStatusInformation? {
        decodeClientStatusCalledAttempt += 1
        return decodeClientStatusResult
    }
    
    
}
