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
    
    @discardableResult func setPublicKey(withData data: Data) -> SecKey?
    
    func password(for username: String) -> String?

    func setPassword(_ password: String?, for username: String)

    func passwordReference(for username: String) -> Data?

    func clear(for username: String)
}
