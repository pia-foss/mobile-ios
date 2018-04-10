//
//  Array+Math.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/12/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

extension Array where Element: BinaryInteger {
    func avg() -> Element? {
        guard !isEmpty else {
            return nil
        }
        return reduce(0, +) / Element(count)
    }
}

extension Array where Element: FloatingPoint {
    func avg() -> Element? {
        guard !isEmpty else {
            return nil
        }
        return reduce(0, +) / Element(count)
    }
}
