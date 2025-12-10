
import Foundation

public protocol UpdateAccountUseCaseType {
    typealias Completion = ((Result<String?, NetworkRequestError>) -> Void)
    
    func setEmail(email: String, resetPassword: Bool, completion: @escaping Completion)
    
    func setEmail(username: String, password: String, email: String, resetPassword: Bool, completion: @escaping Completion)
}


class UpdateAccountUseCase: UpdateAccountUseCaseType {
    
    private let networkClient: NetworkRequestClientType
    private let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType) {
        self.networkClient = networkClient
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
    }
    
    
    func setEmail(email: String, resetPassword: Bool, completion: @escaping Completion) {
        
        refreshAuthTokensChecker.refreshIfNeeded { error in
            if let error {
                completion(.failure(error))
            } else {
                var configuration = UpdateAccountRequestConfiguration()
               
                let bodyDataDict: [String: String] = [
                    "email": email,
                    "reset_password": resetPassword.toString()
                ]
                
                if let bodyData = try? JSONEncoder().encode(bodyDataDict) {
                    configuration.body = bodyData
                }
                
                self.executeNetworkRequest(with: configuration, completion: completion)
            }
        }
    }
    
    func setEmail(username: String, password: String, email: String, resetPassword: Bool, completion: @escaping Completion) {
        
        refreshAuthTokensChecker.refreshIfNeeded { error in
            if let error {
                completion(.failure(error))
            } else {
                var configuration = UpdateAccountRequestConfiguration()
                
                configuration.inlcudeAuthHeaders = false
                
                if let authHeatherValue = "\(username):\(password)".toBase64() {
                    configuration.otherHeaders = ["Authorization": "Basic \(authHeatherValue)"]
                }
                
                let queryParameters: [String: String] = [
                    "email": email,
                    "reset_password": resetPassword.toString()
                ]
                
                configuration.urlQueryParameters = queryParameters
                
                self.executeNetworkRequest(with: configuration, completion: completion)
            }
        }
    }
    
    
}

private extension UpdateAccountUseCase {
    
    func executeNetworkRequest(with configuration: NetworkRequestConfigurationType, completion: @escaping Completion) {
        
        networkClient.executeRequest(with: configuration) { error, dataResponse in
            
            if let error {
                completion(.failure(error))
            } else {
                guard let data = dataResponse?.data else {
                    completion(.failure(.noDataContent))
                    return
                }
                
                let decodedResponse = try?   JSONDecoder().decode([String:String].self, from: data)
                
                let tempPassword = decodedResponse?["password"]
                completion(.success(tempPassword))
                
            }
        }
        
    }
    
}


