//
//  DataManipulation.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation

public extension Data {
    
    func getInt64(start: Int) -> UInt64 {
        let intBits = self.withUnsafeBytes({(bytePointer: UnsafePointer<UInt8>) -> UInt64 in
            bytePointer.advanced(by: start).withMemoryRebound(to: UInt64.self, capacity: 8) { pointer in
                return pointer.pointee
            }
        })
        return UInt64(littleEndian: intBits)
    }
    
}
