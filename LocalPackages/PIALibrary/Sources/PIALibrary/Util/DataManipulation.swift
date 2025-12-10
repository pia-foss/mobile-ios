//
//  DataManipulation.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
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
