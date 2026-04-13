//
//  PIALibrary+Protocols.swift
//  PIALibrary
//
//  Created by Mario on 24/03/2026.
//  Copyright © 2026 Private Internet Access, Inc.
//

import Foundation

public protocol AccountProviderType {
    var isLoggedIn: Bool { get }
    var isExpired: Bool { get }
    var publicUsername: String? { get }
    var currentUser: PIALibrary.UserAccount? { get set }
    func logout(_ callback: ((Error?) -> Void)?)
    func login(with linkToken: String, _ callback: ((PIALibrary.UserAccount?, Error?) -> Void)?)
    func accountInformation(_ callback: ((PIALibrary.AccountInfo?, Error?) -> Void)?)
}

public protocol ServerType {
    var id: ObjectIdentifier { get }
    var name: String { get }
    var identifier: String { get }
    var regionIdentifier: String { get }
    var country: String { get }
    var geo: Bool { get }
    var pingTime: Int? { get }
    var isAutomatic: Bool { get }
    var dipToken: String? { get }
    var dipIKEv2IP: String? { get }
    var dipStatusString: String? { get }
}

public protocol DedicatedIPStatusType {
    func getStatus() -> String
}

public protocol ServerProviderType {
    var historicalServersType: [ServerType] { get }
    var targetServerType: ServerType { get throws }
    var currentServersType: [ServerType] { get }
}

public protocol VPNStatusProviderType {
    var vpnStatus: VPNStatus { get }
    func connect(_ callback: SuccessLibraryCallback?)
    func disconnect(_ callback: SuccessLibraryCallback?)

}

extension DefaultVPNProvider: VPNStatusProviderType {}

extension MockVPNProvider: VPNStatusProviderType {}
