
import Foundation
import PIALibrary


protocol AccountProviderType {
    var isLoggedIn: Bool { get }
    func logout(_ callback: ((Error?) -> Void)?)
}

extension DefaultAccountProvider: AccountProviderType { }
