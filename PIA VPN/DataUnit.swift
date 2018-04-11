//
//  DataUnit.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

enum DataUnit: Int, CustomStringConvertible {
    case bit
    
    case byte
    
    case kilobit
    
    case kilobyte
    
    case megabit
    
    case megabyte
    
    case gigabit
    
    case gigabyte
    
    private static let allNames: [DataUnit: String] = [
        .bit: "Bits",
        .byte: "Bytes",
        .kilobit: "Kilobits",
        .kilobyte: "Kilobytes",
        .megabit: "Megabits",
        .megabyte: "Megabytes",
        .gigabit: "Gigabits",
        .gigabyte: "Gigabytes"
    ]
    
    private static let allBits: [DataUnit: UInt64] = [
        .bit: 1,
        .byte: 8,
        .kilobit: 1000,
        .kilobyte: 8192,
        .megabit: 1000000,
        .megabyte: 8388608,
        .gigabit: 1000000000,
        .gigabyte: 8589934592
    ]
    
    private static let allDescriptions: [DataUnit: String] = [
        .bit: "bit",
        .byte: "B",
        .kilobit: "kbit",
        .kilobyte: "kB",
        .megabit: "Mbit",
        .megabyte: "MB",
        .gigabit: "Gbit",
        .gigabyte: "GB"
    ]
    
    var name: String {
        return DataUnit.allNames[self]!
    }
    
    var bits: UInt64 {
        return DataUnit.allBits[self]!
    }

    var description: String {
        return DataUnit.allDescriptions[self]!
    }
}
