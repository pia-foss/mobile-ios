//
//  Macros.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/21/17.
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

/// A set of useful methods for internal and consumer development.
public class Macros {
    
    /**
     Returns a short version string.
     
     - Returns: The short app version string.
     */
    public static func versionString() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    /**
     Returns a full version string.
     
     - Returns: The full version string, including both x.y.z version and build number.
     */
    public static func versionFullString() -> String? {
        guard let info = Bundle.main.infoDictionary else {
            return nil
        }
        let versionNumber = info["CFBundleShortVersionString"] as! String
        let buildNumber = info[kCFBundleVersionKey as String] as! String
        
        return "\(versionNumber) (\(buildNumber))"
    }
    
    /**
     Dispatches an asynchronous block to the main queue.
 
     - Parameter delay: The `DispatchTimeInterval` after which to dispatch the block from now.
     - Parameter block: The block to execute after `delay`.
     */
    public static func dispatch(after delay: DispatchTimeInterval, block: @escaping () -> Void) {
        let deadline = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: block)
    }

    private init() {
    }
}
