//
//  CredentialsUtil.swift
//  PIA VPN
//
//  Created by Waleed Mahmood on 08.03.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation

public enum CredentialsType: String {
    case valid = "valid"
    case expired = "expired"
    case invalid = "invalid"
}

public struct Credentials: Codable {
    let username: String
    let password: String
    
    init(from dictionary: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

public class CredentialsUtil {
    public static func credentials(type: CredentialsType) -> Credentials {
        let bundle = Bundle(for: CredentialsUtil.self)
        guard let filePath = bundle.path(forResource: "Credentials", ofType: "plist") else {
            fatalError("Couldn't find file 'Credentials.plist'")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let dictionary = plist?.object(forKey: type.rawValue) as? [String: String] else {
            fatalError("Couldn't find key '\(type.rawValue)' in 'Credentials.plist'")
        }
        
        do {
            return try Credentials(from: dictionary)
        }
        catch {
             fatalError("Credential file does not contain required information")
        }
    }
}
