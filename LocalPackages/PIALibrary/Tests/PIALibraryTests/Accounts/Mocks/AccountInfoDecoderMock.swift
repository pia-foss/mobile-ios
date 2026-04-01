
import Foundation
@testable import PIALibrary

class AccountInfoDecoderMock: AccountInfoDecoderType {
    
    private(set) var decodeAccountInfoCalledAttempt = 0
    var decodeAccountInfoResult: AccountInfo?
    func decodeAccountInfo(from data: Data) -> AccountInfo? {
        decodeAccountInfoCalledAttempt += 1
        return decodeAccountInfoResult
    }
    
    
    
}
