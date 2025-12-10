//
//  DateUtil.swift
//  PIALibrary
//  
//  Created by Jose Blaya on 04/12/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation

public extension Date {
    
    public func removing(minutes: Int) -> Date? {
        let result =  Calendar.current.date(byAdding: .minute, value: -(minutes), to: self)
        return result
    }
    
    public func removing(hours: Int) -> Date? {
        let result =  Calendar.current.date(byAdding: .hour, value: -(hours), to: self)
        return result
    }

    public func removing(days: Int) -> Date? {
        let result =  Calendar.current.date(byAdding: .day, value: -(days), to: self)
        return result
    }

    public var epochMilliseconds: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
