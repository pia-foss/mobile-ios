
import Foundation
import NWHttpConnection

private let log = PIALogger.logger(for: RefreshAPITokenUseCase.self)

protocol RefreshAPITokenUseCaseType {
    typealias Completion = ((NetworkRequestError?) -> Void)
    func callAsFunction(completion: @escaping RefreshAPITokenUseCaseType.Completion)
}

class RefreshAPITokenUseCase: RefreshAPITokenUseCaseType {
    
    private let apiTokenProvider: APITokenProviderType
    private let networkClient: NetworkRequestClientType
    
    init(apiTokenProvider: APITokenProviderType, networkClient: NetworkRequestClientType) {
        self.apiTokenProvider = apiTokenProvider
        self.networkClient = networkClient
    }
    
    func callAsFunction(completion: @escaping RefreshAPITokenUseCaseType.Completion) {
        let configuration = RefreshApiTokenRequestConfiguration()
        
        networkClient.executeRequest(with: configuration) { [weak self] error, dataResponse in
            if let error {
                // Clear old token on refresh failure to prevent repeated auth failures
                log.info("Clearing API token due to error: \(error)")
                self?.apiTokenProvider.clearAPIToken()
                completion(error)
            } else if let dataResponse {
                self?.handleDataResponse(dataResponse, completion: completion)
            } else {
                // Clear old token on refresh failure to prevent repeated auth failures
                log.info("Clearing API token due to allConnectionAttemptsFailed (no error and no response)")
                self?.apiTokenProvider.clearAPIToken()
                completion(NetworkRequestError.allConnectionAttemptsFailed())
            }
        }
    }
    
}


private extension RefreshAPITokenUseCase {

    private func handleDataResponse(_ dataResponse: NetworkRequestResponseType, completion: @escaping RefreshAPITokenUseCaseType.Completion) {
        guard let dataResponseContent = dataResponse.data else {
            // Clear old token on refresh failure to prevent repeated auth failures
            log.info("Clearing API token due to noDataContent in response")
            apiTokenProvider.clearAPIToken()
            completion(NetworkRequestError.noDataContent)
            return
        }
        
        do {
            try apiTokenProvider.saveAPIToken(from: dataResponseContent)
            completion(nil)
        } catch {
            // Clear old token when unable to save new one to prevent repeated auth failures
            log.info("Clearing API token due to save failure - error: \(error)")
            apiTokenProvider.clearAPIToken()
            completion(NetworkRequestError.unableToSaveAPIToken)
        }
    }
    
}
