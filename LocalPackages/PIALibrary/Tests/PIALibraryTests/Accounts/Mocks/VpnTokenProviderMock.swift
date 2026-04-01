import Foundation
@testable import PIALibrary

class VpnTokenProviderMock: VpnTokenProviderType {
    
    var getVpnTokenCalledAttempt = 0
    var getVpnTokenResult: VpnToken?
    func getVpnToken() -> VpnToken? {
        getVpnTokenCalledAttempt += 1
     return getVpnTokenResult
    }
    
    var saveVpnTokenCalledAttempt = 0
    var saveVpnTokenCalledWithArg: VpnToken?
    func save(vpnToken: VpnToken) {
        saveVpnTokenCalledAttempt += 1
        saveVpnTokenCalledWithArg = vpnToken
    }
    
    var saveVpnTokenFromDataCalledAttempt = 0
    var saveVpnTokenFromDataCalledWithArg: Data?
    var saveVpnTokenFromDataError: NetworkRequestError?
    func saveVpnToken(from data: Data) throws {
        saveVpnTokenFromDataCalledAttempt += 1
        saveVpnTokenFromDataCalledWithArg = data
        if let saveVpnTokenFromDataError {
            throw saveVpnTokenFromDataError
        }
    }
    
    var clearVpnTokenCalledAttempt = 0
    func clearVpnToken() {
        clearVpnTokenCalledAttempt += 1
    }
}

