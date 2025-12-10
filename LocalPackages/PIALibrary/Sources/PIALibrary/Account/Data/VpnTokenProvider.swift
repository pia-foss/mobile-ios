
import Foundation

protocol VpnTokenProviderType {
    func getVpnToken() -> VpnToken?
    func save(vpnToken: VpnToken)
    func saveVpnToken(from data: Data) throws
    func clearVpnToken()
}


class VpnTokenProvider: VpnTokenProviderType {
    private let keychainStore: SecureStore
    let tokenSerializer: AuthTokenSerializerType
    private let vpnTokenKey = "VPN_TOKEN_KEY"
    
    init(keychainStore: SecureStore, tokenSerializer: AuthTokenSerializerType) {
        self.keychainStore = keychainStore
        self.tokenSerializer = tokenSerializer
    }
    
    func getVpnToken() -> VpnToken? {
        guard let tokenDataString = keychainStore.token(for: vpnTokenKey),
              let tokenData = tokenDataString.data(using: .utf8) else { return nil }
        return tokenSerializer.decodeVpnToken(from: tokenData)
    }
    
    func save(vpnToken: VpnToken) {
        guard let encodedToken = tokenSerializer.encode(vpnToken: vpnToken) else { return }
        keychainStore.setPassword(encodedToken, for: vpnTokenKey)
    }
    
    func saveVpnToken(from data: Data) throws {
        guard let vpnToken = tokenSerializer.decodeVpnToken(from: data) else {
            throw NetworkRequestError.unableToDecodeVpnToken
        }
        
        save(vpnToken: vpnToken)
    }
    
    func clearVpnToken() {
        keychainStore.clearToken(for: vpnTokenKey)
    }
        
}
