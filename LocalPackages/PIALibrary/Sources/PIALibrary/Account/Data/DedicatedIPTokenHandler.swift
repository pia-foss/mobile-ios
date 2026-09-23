import Foundation

final class DedicatedIPTokenHandler: DedicatedIPTokenHandlerType {
    // Resolved per call: providers can be built before the app sets its app-group database.
    private let secureStore: @Sendable () -> SecureStore

    init(secureStore: @escaping @Sendable () -> SecureStore) {
        self.secureStore = secureStore
    }

    func callAsFunction(dedicatedIp: DedicatedIPInformation, dipUsername: String) {
        if dedicatedIp.isAboutToExpire {
            Macros.postNotification(.PIADIPRegionExpiring, [.token: dedicatedIp.dipToken])
        }

        Macros.postNotification(.PIADIPCheckIP, [.token: dedicatedIp.dipToken, .ip: dedicatedIp.ip!])

        let secureStore = secureStore()
        secureStore.setDIPToken(dedicatedIp.dipToken)
        secureStore.setPassword(dedicatedIp.ip!, forDipToken: dipUsername)
    }
}
