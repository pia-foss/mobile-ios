
import Foundation

class DedicatedIPTokenHandler: DedicatedIPTokenHandlerType {
    private let secureStore: SecureStore
    
    init(secureStore: SecureStore) {
        self.secureStore = secureStore
    }
    
    func callAsFunction(dedicatedIp: DedicatedIPInformation, dipUsername: String) {
        if dedicatedIp.isAboutToExpire {
            Macros.postNotification(.PIADIPRegionExpiring, [.token : dedicatedIp.dipToken])
        }

        Macros.postNotification(.PIADIPCheckIP, [.token : dedicatedIp.dipToken, .ip : dedicatedIp.ip!])
        
        secureStore.setDIPToken(dedicatedIp.dipToken)
        secureStore.setPassword(dedicatedIp.ip!, forDipToken: dipUsername)
    }
}
