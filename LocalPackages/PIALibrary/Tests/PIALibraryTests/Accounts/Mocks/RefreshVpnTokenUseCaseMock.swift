
import Foundation
@testable import PIALibrary

class RefreshVpnTokenUseCaseMock: RefreshVpnTokenUseCaseType {
    
    var callAsFunctionCalledAttempt = 0
    var completionError: NetworkRequestError?
    
    func callAsFunction(completion: @escaping ((NetworkRequestError?) -> Void)) {
        callAsFunctionCalledAttempt += 1
        completion(completionError)
    }
}

