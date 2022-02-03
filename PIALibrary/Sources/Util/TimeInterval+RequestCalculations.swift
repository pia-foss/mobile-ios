//
//  TimeInterval+RequestCalculations.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 03.02.22.
//

import Foundation


public extension TimeInterval {
    /// Returns time in seconds between receiver & now
    /// and a nil if now has already gone ahead of the receiver.
    public func timeSinceNow() -> Double? {
        let now = Date().timeIntervalSince1970
        return now > self ? nil : self - now
    }
}
