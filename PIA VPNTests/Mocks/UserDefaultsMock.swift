//
//  UserDefaultsMock.swift
//  PIA VPNTests
//
//  Created by Laura S on 4/25/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN

class UserDefaultsMock: UserDefaultsType {
    static func resetStandardUserDefaults() {
        
    }
    
    required init?(suiteName suitename: String?) {
        
    }
    
    var objectResult: Any?
    func object(forKey defaultName: String) -> Any? {
        return objectResult
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
    }
    
    func set(_ value: Bool, forKey: String) {
        
    }
    
    func removeObject(forKey defaultName: String) {
        
    }
    
    var stringResult: String?
    func string(forKey defaultName: String) -> String? {
        return stringResult
    }
    
    var boolResult: Bool = false
    func bool(forKey defaultName: String) -> Bool {
            return boolResult
    }
    
    func set(_ value: Int, forKey defaultName: String) {
        
    }
    
    var integerResult: Int = 0
    func integer(forKey defaultName: String) -> Int {
        return integerResult
    }
    
    private(set) var setDateAttempt = 0
    private(set) var setDateCalledWithArguments: (date: Date?, key: String)?
    func set(date: Date?, forKey key: String) {
        setDateAttempt += 1
        setDateCalledWithArguments = (date: date, key: key)
    }
    
    var dateResult: Date?
    func date(forKey key: String) -> Date? {
        return dateResult
    }
    
    
    func removePersistentDomain(forName: String) {
        
    }
    
    var synchronizeResult: Bool = true
    func synchronize() -> Bool {
        return synchronizeResult
    }
    
    
}
