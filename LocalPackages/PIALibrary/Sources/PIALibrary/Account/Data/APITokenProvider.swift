
import Foundation

protocol APITokenProviderType {
    func getAPIToken() -> APIToken?
    func save(apiToken: APIToken)
    func saveAPIToken(from data: Data) throws
    func clearAPIToken()
}

class APITokenProvider: APITokenProviderType {
    private let keychainStore: SecureStore
    let tokenSerializer: AuthTokenSerializerType
    private let apiTokenKey = "API_TOKEN_KEY"
    
    init(keychainStore: SecureStore, tokenSerializer: AuthTokenSerializerType) {
        self.keychainStore = keychainStore
        self.tokenSerializer = tokenSerializer
    }
    
    func getAPIToken() -> APIToken? {
        guard let tokenDataString = keychainStore.token(for: apiTokenKey),
              let tokenData = tokenDataString.data(using: .utf8) else { return nil }
        return tokenSerializer.decodeAPIToken(from: tokenData)
    }
    
    func save(apiToken: APIToken) {
        guard let encodedToken = tokenSerializer.encode(apiToken: apiToken) else { return }
        keychainStore.setPassword(encodedToken, for: apiTokenKey)
    }
    
    func saveAPIToken(from data: Data) throws {
        guard let apiToken = tokenSerializer.decodeAPIToken(from: data) else {
            throw NetworkRequestError.unableToDecodeAPIToken
        }
        
        save(apiToken: apiToken)
    }
    
    func clearAPIToken() {
        keychainStore.clearToken(for: apiTokenKey)
    }
    
}
