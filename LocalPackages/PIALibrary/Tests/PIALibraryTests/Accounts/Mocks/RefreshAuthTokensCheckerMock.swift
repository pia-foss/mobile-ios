

import Foundation
@testable import PIALibrary

class RefreshAuthTokensCheckerMock: RefreshAuthTokensCheckerType {
    
    var refreshIfNeededCalledAttempt = 0
    var refreshIfNeededError: NetworkRequestError? = nil
    func refreshIfNeeded(completion: @escaping Completion) {
        refreshIfNeededCalledAttempt += 1
        completion(refreshIfNeededError)
    }
    
    
}
