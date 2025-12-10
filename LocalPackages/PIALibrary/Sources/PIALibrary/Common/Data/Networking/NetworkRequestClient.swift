
import Foundation
import NWHttpConnection


protocol NetworkRequestClientType {
    typealias Completion = ((NetworkRequestError?, NetworkRequestResponseType?) -> Void)
    func executeRequest(with configuration: NetworkRequestConfigurationType, completion: @escaping Completion)
}


class NetworkRequestClient: NetworkRequestClientType {
    private let networkConnectionRequestProvider: NetworkConnectionRequestProviderType
    private let endpointManager: EndpointManagerType
    
    init(networkConnectionRequestProvider: NetworkConnectionRequestProviderType, endpointManager: EndpointManagerType) {
        self.networkConnectionRequestProvider = networkConnectionRequestProvider
        self.endpointManager = endpointManager
    }
    
    func executeRequest(with configuration: NetworkRequestConfigurationType, completion: @escaping Completion) {

        startRequest(with: configuration, completion: completion)
    }
    
}

// MARK: - Private

private extension NetworkRequestClient {
    
    func startRequest(with configuration: NetworkRequestConfigurationType, completion: @escaping Completion) {
        let endpoints = getEndpoints(for: configuration.networkRequestModule)

        let connections = endpoints.compactMap { endpoint in
            self.networkConnectionRequestProvider.makeNetworkRequestConnection(for: endpoint, with: configuration)
        }
        
        // Runs recursevly all the connections until one succeeds or all fail
        executeRecursivelyUntilSuccess(connections: connections, completion: completion)
    }
    
    /// Serial execution of all the connections until one succeeds or completes with an error when all connection attempts fail
    func executeRecursivelyUntilSuccess(connections:  [NWHttpConnectionType], completion: @escaping NetworkRequestClientType.Completion) {
        
        guard !connections.isEmpty else {
            completion(.allConnectionAttemptsFailed(statusCode: nil), nil)
            return
        }
        
        var remainingConnections = connections
        let nextConnection = remainingConnections.removeFirst()
        
        func tryNextConnectionOrFail(currentStatusCode: Int?) {
            if remainingConnections.isEmpty {
                // No more endpoints to try a connection
                let requestError = NetworkRequestError.allConnectionAttemptsFailed(statusCode: currentStatusCode)
                completion(requestError, nil)
            } else {
                // Continue with the next connection
                executeRecursivelyUntilSuccess(connections: remainingConnections, completion: completion)
            }
        }
        
        execute(connection: nextConnection) { error, responseData in

            if error != nil {
                tryNextConnectionOrFail(currentStatusCode: responseData?.statusCode)
            } else if let responseData {
                let statusCode: Int = responseData.statusCode ?? -1
                let isSuccessStatusCode = statusCode > 199 && statusCode < 300
                
                if isSuccessStatusCode {
                    completion(nil, responseData)
                } else {
                    // Connection did not succeed, try the next one
                    tryNextConnectionOrFail(currentStatusCode: responseData.statusCode)
                }
            } else {
                // No error and no data
                tryNextConnectionOrFail(currentStatusCode: nil)
            }
        }
        
    }
    
    /// Execution of a single connection
    func execute(connection: NWHttpConnectionType, completion: @escaping NetworkRequestClientType.Completion) {
        do {
            var connectionHandled: Bool = false
            
            try connection.connect { error, dataResponse in
                if let error {
                    connectionHandled = true
                    completion(NetworkRequestError.connectionError(statusCode: dataResponse?.statusCode, message: error.localizedDescription), nil)
                } else if let dataResponse = dataResponse as? NetworkRequestResponseType {
                    connectionHandled = true
                    completion(nil, dataResponse)
                } else {
                    connectionHandled = true
                    completion(NetworkRequestError.noErrorAndNoResponse, nil)
                }
            } completion: {
                if connectionHandled == false {
                    completion(NetworkRequestError.connectionCompletedWithNoResponse, nil)
                }
            }
            
        } catch {
            completion(NetworkRequestError.unknown(message: error.localizedDescription), nil)
        }
    }
    
    func getEndpoints(for module: NetworkRequestModule, environment: Client.Environment = Client.environment) -> [PinningEndpoint] {
        switch (module, environment) {
        case (.account, .production):
            return endpointManager.availableEndpoints()
        case (.account, .staging):
            return [
                PinningEndpoint(host: Client.configuration.baseUrl, isProxy: false, useCertificatePinning: false)
            ]
        }
    }
}
