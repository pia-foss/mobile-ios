
import Foundation
import PIALibrary


protocol AccountProviderType {
    var isLoggedIn: Bool { get }
    func logout(_ callback: ((Error?) -> Void)?)
}

extension DefaultAccountProvider: AccountProviderType { }

protocol ServerType {
    var name: String { get }
    var identifier: String { get }
    var regionIdentifier: String { get }
    var country: String { get }
    var geo: Bool { get }
}

extension Server: ServerType {}
