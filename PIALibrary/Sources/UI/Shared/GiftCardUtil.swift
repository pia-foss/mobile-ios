//
//  GiftCardUtil.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 20/8/18.
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

public class GiftCardUtil {
    
    private static let rxCodeGrouping: NSRegularExpression = try! NSRegularExpression(pattern: "\\d{4}(?=\\d)", options: [])
    
    private static let sixteenDigitRegex: NSRegularExpression = try! NSRegularExpression(pattern: "\\d{16}", options: [])
    private static let strippedSixteenDigitRegex: NSRegularExpression = try! NSRegularExpression(pattern: "\\b\\d{4}(| |-)\\d{4}\\1\\d{4}\\1\\d{4}\\b", options: [])

    /**
     Add the stripped format to a given gift card code.
     
     - Parameter code: The code to be formatted.
     - Returns: String the code with the stripped format.
     */
    public static func friendlyRedeemCode(_ code: String) -> String {
        return GiftCardUtil.rxCodeGrouping.stringByReplacingMatches(in: code,
                                                                    options: [],
                                                                    range: NSMakeRange(0, code.count),
                                                                    withTemplate: "$0-")
    }
    
    /**
     Remove all stripped occurrences.
     
     - Parameter code: The code to replace.
     - Returns: String without the found occurrences.
     */
    public static func strippedRedeemCode(_ code: String) -> String {
        return code.replacingOccurrences(of: "-", with: "")
    }
    
    /**
     This function extracts the redeem code from any String.
     
     - Parameter code: The redeem code string.
     - Parameter stripped: Option to remove - characters after extract the redeem code.
     - Returns: The 16-digit redeem code .
     */
    public static func extractRedeemCode(_ code: String,
                                         strippedFormat stripped: Bool = false) -> String? {
        
        if let finalResult = findBySixteenDigitOnly(code),
            finalResult.count > 0 {
            if let result = finalResult.first {
                if stripped {
                    return strippedRedeemCode(result)
                }
                return result
            }
        } else if let finalResult = findBySixteenDigitStrippedOnly(code),
            finalResult.count > 0 {
            if let result = finalResult.first {
                if stripped {
                    return strippedRedeemCode(result)
                }
                return result
            }
        }

        return nil
        
    }
    
    private static func findBySixteenDigitOnly(_ code: String) -> [String]? {
        
        let matches = sixteenDigitRegex.matches(in: code,
                                                options: [],
                                                range: NSMakeRange(0, code.count))
        
        return self.findOccurrencesInRegex(matches,
                                           forCode: code)

    }
    
    private static func findBySixteenDigitStrippedOnly(_ code: String) -> [String]? {
        
        let matches = strippedSixteenDigitRegex.matches(in: code,
                                                options: [],
                                                range: NSMakeRange(0, code.count))
        
        return self.findOccurrencesInRegex(matches,
                                           forCode: code)

    }
    
    private static func findOccurrencesInRegex(_ matches: [NSTextCheckingResult],
                                               forCode code: String) -> [String]? {
        
        var finalResult = [String]()
        if matches.count > 0 {
            finalResult = matches.map {
                if let range = Range($0.range,
                                     in: code) {
                    return String(code[range])
                }
                return ""
            }
        }
        
        return finalResult

    }
}
