
import Foundation
@testable import PIALibrary

class APITokenProviderMock: APITokenProviderType {
    
    var getAPITokenCalledAttempt = 0
    var getAPITokenResult: APIToken?
    func getAPIToken() -> APIToken? {
        getAPITokenCalledAttempt += 1
     return getAPITokenResult
    }
    
    var saveAPITokenCalledAttempt = 0
    var saveAPITokenCalledWithArg: APIToken?
    func save(apiToken: APIToken) {
        saveAPITokenCalledAttempt += 1
        saveAPITokenCalledWithArg = apiToken
    }
    
    var saveAPITokenFromDataCalledAttempt = 0
    var saveAPITokenFromDataCalledWithArg: Data?
    var saveAPITokenFromDataError: NetworkRequestError? = nil
    func saveAPIToken(from data: Data) throws {
        saveAPITokenFromDataCalledAttempt += 1
        saveAPITokenFromDataCalledWithArg = data
        if let saveAPITokenFromDataError {
            throw saveAPITokenFromDataError
        }
    }
    
    var clearAPITokenCalledAttempt = 0
    func clearAPIToken() {
        clearAPITokenCalledAttempt += 1
    }
}
