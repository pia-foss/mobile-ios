//
//  GiftCardUtil.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 20/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

public class GiftCardUtil {
    
    private static let rxCodeGrouping: NSRegularExpression = try! NSRegularExpression(pattern: "\\d{4}(?=\\d)", options: [])

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
     Removes all whitespaces, dashes or minus characters.
     
     - Parameter code: The code to replace.
     - Returns: String without the found occurrences.
     */
    public static func plainRedeemCode(_ code: String) -> String {
        var formattedCode = self.strippedRedeemCode(code)
        formattedCode = formattedCode.replacingOccurrences(of: "#", with: "")
        formattedCode = formattedCode.components(separatedBy: .whitespacesAndNewlines).joined()
        return formattedCode
    }
}
