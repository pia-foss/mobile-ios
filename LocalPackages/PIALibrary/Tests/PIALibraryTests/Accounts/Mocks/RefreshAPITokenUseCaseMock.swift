
import Foundation
@testable import PIALibrary

class RefreshAPITokenUseCaseMock: RefreshAPITokenUseCaseType {
    
    var callAsFunctionCalledAttempt = 0
    var completionError: NetworkRequestError?
    
    func callAsFunction(completion: @escaping ((NetworkRequestError?) -> Void)) {
        callAsFunctionCalledAttempt += 1
        completion(completionError)
    }
}
