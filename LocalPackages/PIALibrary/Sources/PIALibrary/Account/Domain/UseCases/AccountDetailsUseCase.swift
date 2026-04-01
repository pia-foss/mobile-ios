
import Foundation

public protocol AccountDetailsUseCaseType {
    typealias Completion = ((Result<AccountInfo, NetworkRequestError>) -> Void)
    func callAsFunction(completion: @escaping Completion)
}


class AccountDetailsUseCase: AccountDetailsUseCaseType {
    
    private let networkClient: NetworkRequestClientType
    private let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    private let accountInfoDecoder: AccountInfoDecoderType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType, accountInforDecoder: AccountInfoDecoderType) {
        self.networkClient = networkClient
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
        self.accountInfoDecoder = accountInforDecoder
    }
    
    func callAsFunction(completion: @escaping Completion) {
        refreshAuthTokensChecker.refreshIfNeeded { error in
            if let error {
                completion(.failure(error))
            } else {
                let configuration = AccountDetailsRequestConfiguration()
                self.networkClient.executeRequest(with: configuration) { error, response in
                    
                    if let error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let respData = response?.data else {
                        completion(.failure(.connectionError(statusCode: response?.statusCode, message: "No data found in the response")))
                        return
                    }
                
                    guard let accountInfo = self.accountInfoDecoder.decodeAccountInfo(from: respData) else {
                        completion(.failure(.connectionError(statusCode: response?.statusCode, message: "Unable to decode accountInfo")))
                        return
                    }
                    
                    completion(.success(accountInfo))
                    
                }
            }
        }
    }
}
