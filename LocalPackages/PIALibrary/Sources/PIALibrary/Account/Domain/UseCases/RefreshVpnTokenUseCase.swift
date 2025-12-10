
import Foundation

protocol RefreshVpnTokenUseCaseType {
    typealias Completion = ((NetworkRequestError?) -> Void)
    func callAsFunction(completion: @escaping RefreshVpnTokenUseCaseType.Completion)
}

class RefreshVpnTokenUseCase: RefreshVpnTokenUseCaseType {
    
    private let vpnTokenProvider: VpnTokenProviderType
    private let networkClient: NetworkRequestClientType
    
    init(vpnTokenProvider: VpnTokenProviderType, networkClient: NetworkRequestClientType) {
        self.vpnTokenProvider = vpnTokenProvider
        self.networkClient = networkClient
    }
    
    func callAsFunction(completion: @escaping RefreshVpnTokenUseCaseType.Completion) {
        
        let configuration = RefreshVpnTokenRequestConfiguration()
        
        networkClient.executeRequest(with: configuration) { [weak self] error, dataResponse in
            guard let self else { return }
            
            if let error {
                completion(error)
            } else if let dataResponse {
                self.handleDataResponse(dataResponse, completion: completion)
            } else {
                completion(NetworkRequestError.allConnectionAttemptsFailed())
            }
            
        }
    }
        
}


private extension RefreshVpnTokenUseCase {
    private func handleDataResponse(_ dataResponse: NetworkRequestResponseType, completion: @escaping RefreshVpnTokenUseCaseType.Completion) {
        
        guard let dataResponseContent = dataResponse.data else {
            completion(NetworkRequestError.noDataContent)
            return
        }
        
        do {
            try vpnTokenProvider.saveVpnToken(from: dataResponseContent)
            completion(nil)
        } catch {
            completion(NetworkRequestError.unableToSaveVpnToken)
        }
        
    }
    
}
