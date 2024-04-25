//
//  Foundation+PIA.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 13/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

extension TimeInterval {
    /// Returns time in seconds between receiver & now
    /// and a nil if now has already gone ahead of the receiver.
    public func timeSinceNow() -> Double? {
        let now = Date().timeIntervalSince1970
        return now > self ? nil : self - now
    }
    
    /// Returns time in seconds between now & the receiver
    /// and a nil if the receiver has already gone ahead of now.
    public func timeUntilNow() -> Double? {
        let now = Date().timeIntervalSince1970
        return now < self ? nil : now - self
    }
}
