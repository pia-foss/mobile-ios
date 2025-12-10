
import Foundation

public protocol LoginUseCaseType {
    typealias Completion = ((NetworkRequestError?) -> Void)
    func login(with credentials: Credentials, completion: @escaping Completion)
    func login(with receipt: Data, completion: @escaping Completion)
    func loginLink(with email: String, completion: @escaping Completion)
}

class LoginUseCase: LoginUseCaseType {
    private let networkClient: NetworkRequestClientType
    private let apiTokenProvider: APITokenProviderType
    private let refreshVpnTokenUseCase: RefreshVpnTokenUseCaseType
    
    init(networkClient: NetworkRequestClientType, apiTokenProvider: APITokenProviderType, refreshVpnTokenUseCase: RefreshVpnTokenUseCaseType) {
        self.networkClient = networkClient
        self.apiTokenProvider = apiTokenProvider
        self.refreshVpnTokenUseCase = refreshVpnTokenUseCase
    }
    
    func login(with credentials: Credentials, completion: @escaping Completion) {
        
        var configuration = LoginRequestConfiguration()
        let bodyDataDict: [String: String] = [
            "username": credentials.username,
            "password": credentials.password
        ]
        
        if let bodyData = try? JSONEncoder().encode(bodyDataDict) {
            configuration.body = bodyData
        }
        
        executeNetworkRequest(with: configuration, completion: completion)
    }
    
    func login(with receipt: Data, completion: @escaping Completion) {
        
        var configuration = LoginRequestConfiguration()

        let bodyDataDict = [
            "store": "apple_app_store",
            "receipt": receipt.base64EncodedString()
        ]
        
        
        if let bodyData = try? JSONEncoder().encode(bodyDataDict) {
            configuration.body = bodyData
        }
        
        executeNetworkRequest(with: configuration, completion: completion)
    }
    
    
    func loginLink(with email: String, completion: @escaping Completion) {
        
        var configuration = LoginLinkRequestConfiguration()
        let bodyDataDict: [String: String] = [
            "email": email
        ]
        
        if let bodyData = try? JSONEncoder().encode(bodyDataDict) {
            configuration.body = bodyData
        }
        
        executeNetworkRequest(with: configuration, completion: completion)
    }
}

private extension LoginUseCase {
    
    func executeNetworkRequest(with configuration: NetworkRequestConfigurationType, completion: @escaping Completion) {
        
        networkClient.executeRequest(with: configuration) {[weak self] error, dataResponse in
            
            guard let self else { return }
            
            if error != nil {

                completion(.unauthorized)
            } else if let dataResponse {
                let shouldSaveToken = configuration.path == .login
                self.handleDataResponse(dataResponse, shouldSaveTokenFromResponse: shouldSaveToken, completion: completion)
            } else {
                completion(.unauthorized)
            }
        }
    }
    
    func handleDataResponse(_ dataResponse: NetworkRequestResponseType, shouldSaveTokenFromResponse: Bool, completion: @escaping RefreshVpnTokenUseCaseType.Completion) {
        
        if shouldSaveTokenFromResponse {
            guard let dataResponseContent = dataResponse.data else {
                completion(.unauthorized)
                return
            }
            saveAPIToken(from: dataResponseContent, completion: completion)
        } else {
            completion(nil)
        }
        
    }
    
    func saveAPIToken(from data: Data, completion: @escaping Completion) {
        do {
            try apiTokenProvider.saveAPIToken(from: data)
            // Refresh the Vpn token after successfully login
           refreshVpnTokenUseCase() { error in
               if error != nil {
                   completion(.unauthorized)
               } else {
                   completion(nil)
               }
            }
            
        } catch {
            completion(.unauthorized)
        }
    }
}
