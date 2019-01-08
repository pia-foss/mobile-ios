//
//  PropertyStoring.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 28/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

protocol PropertyStoring {
    
    associatedtype T
    
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
}

extension PropertyStoring {
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
        guard let value = objc_getAssociatedObject(self, key) as? T else {
            return defaultValue
        }
        return value
    }
}
