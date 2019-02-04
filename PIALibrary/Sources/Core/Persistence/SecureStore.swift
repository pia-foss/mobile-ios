//
//  SecureStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol SecureStore: class {
    var publicKey: SecKey? { get }
    
    @discardableResult func publicKeyEntry() -> SecKey?

    @discardableResult func setPublicKey(withData data: Data) -> SecKey?
    
    func username() -> String?
    
    func setUsername(_ username: String?)
    
    func publicUsername() -> String?
    
    func setPublicUsername(_ username: String?)
    
    func password(for username: String) -> String?

    func setPassword(_ password: String?, for username: String)

    func passwordReference(for username: String) -> Data?

    func token(for username: String) -> String?
    
    func setToken(_ token: String?, for username: String)
    
    func tokenReference(for username: String) -> Data?
    
    func tokenKey(for username: String) -> String

    func clear(for username: String)
}
