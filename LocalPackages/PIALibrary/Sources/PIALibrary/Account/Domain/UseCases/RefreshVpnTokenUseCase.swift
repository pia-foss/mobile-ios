
import Foundation

private let log = PIALogger.logger(for: RefreshVpnTokenUseCase.self)

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
            if let error {
                // Clear old token on refresh failure to prevent repeated auth failures
                log.info("Clearing VPN token due to error: \(error)")
                self?.vpnTokenProvider.clearVpnToken()
                completion(error)
            } else if let dataResponse {
                self?.handleDataResponse(dataResponse, completion: completion)
            } else {
                // Clear old token on refresh failure to prevent repeated auth failures
                log.info("Clearing VPN token due to allConnectionAttemptsFailed (no error and no response)")
                self?.vpnTokenProvider.clearVpnToken()
                completion(NetworkRequestError.allConnectionAttemptsFailed())
            }
        }
    }

}


private extension RefreshVpnTokenUseCase {

    private func handleDataResponse(_ dataResponse: NetworkRequestResponseType, completion: @escaping RefreshVpnTokenUseCaseType.Completion) {
        guard let dataResponseContent = dataResponse.data else {
            // Clear old token on refresh failure to prevent repeated auth failures
            log.info("Clearing VPN token due to noDataContent in response")
            vpnTokenProvider.clearVpnToken()
            completion(NetworkRequestError.noDataContent)
            return
        }
        
        do {
            try vpnTokenProvider.saveVpnToken(from: dataResponseContent)
            completion(nil)
        } catch {
            // Clear old token when unable to save new one to prevent repeated auth failures
            log.info("Clearing VPN token due to save failure - error: \(error)")
            vpnTokenProvider.clearVpnToken()
            completion(NetworkRequestError.unableToSaveVpnToken)
        }
    }
}
