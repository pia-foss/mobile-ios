
import Foundation

public protocol GenerateQRLoginUseCaseType {
    typealias Completion = ((Result<Data, ClientError>) -> Void)
    func callAsFunction(completion: @escaping Completion)
}

public class GenerateQRLoginUseCase: GenerateQRLoginUseCaseType {
    private let networkClient: NetworkRequestClientType
    
    init(networkClient: NetworkRequestClientType) {
        self.networkClient = networkClient
    }
    
    public func callAsFunction(completion: @escaping Completion) {
        var configuration = GenerateQRRequestConfiguration()
        executeNetworkRequest(with: configuration, completion: completion)
    }
}

private extension GenerateQRLoginUseCase {
    func executeNetworkRequest(with configuration: NetworkRequestConfigurationType, completion: @escaping Completion) {
        networkClient.executeRequest(with: configuration) { [weak self] error, dataResponse in
            guard let self else { return }
            
            if let data = dataResponse?.data {
                completion(.success(data))
            } else {
                completion(.failure(.unauthorized))
            }
        }
    }
}
