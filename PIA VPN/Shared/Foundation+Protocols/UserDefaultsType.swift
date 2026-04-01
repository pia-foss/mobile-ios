//
//  UserDefaultsType.swift
//  PIA VPN
//
//  Created by Laura S on 4/25/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

public protocol UserDefaultsType {
    static func resetStandardUserDefaults()
    
    init?(suiteName suitename: String?)
    
    func object(forKey defaultName: String) -> Any?
    
    func set(_ value: Any?, forKey defaultName: String)
    
    func set(_ value: Bool, forKey: String)
    
    func removeObject(forKey defaultName: String)
    
    func string(forKey defaultName: String) -> String?
    
    func bool(forKey defaultName: String) -> Bool
    
    func set(_ value: Int, forKey defaultName: String)
    
    func integer(forKey defaultName: String) -> Int
    
    func set(date: Date?, forKey key: String)
    
    func date(forKey key: String) -> Date?
    
    func removePersistentDomain(forName: String)
    
    @discardableResult
    func synchronize() -> Bool
}

extension UserDefaults {
    public func set(date: Date?, forKey key: String) {
        self.set(date, forKey: key)
    }
    
    public func date(forKey key: String) -> Date? {
        return self.value(forKey: key) as? Date
    }
}

extension UserDefaults: UserDefaultsType {}
