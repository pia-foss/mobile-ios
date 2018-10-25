//
//  DNSList.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 23/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

class DNSList: NSObject {
    
    static let shared = DNSList()
    static let CUSTOM_DNS_KEY: String = "Custom"

    private(set) var dnsList: [[String:[String]]]!
    private var plistPathInDocument: String!
    
    private override init() {
        super.init()
        self.preparePlistForUse()
        self.load(from: self.plistPathInDocument)
    }
    
    /// Load the values of the plist into the dnsList object
    /// - Parameters:
    ///   - path:  The local path of the plist file.
    private func load(from path: String) {
        guard let dnsList = NSArray(contentsOfFile: path) as? [[String:[String]]] else {
            fatalError("Couldn't load plist from \(path)")
        }
        self.dnsList = dnsList
    }
    
    /// Creates a new dns.plist file in the document directory if it doesn't exist
    private func preparePlistForUse(){

        if let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .userDomainMask,
                                                              true).first {

            plistPathInDocument = rootPath.appendingFormat("/DNS.plist")
            if !FileManager.default.fileExists(atPath: plistPathInDocument){
                if let path = Bundle.main.path(forResource: "DNS", ofType: "plist") {
                    do {
                        try FileManager.default.copyItem(atPath: path,
                                                         toPath: plistPathInDocument)
                    }catch{
                        fatalError("Error occurred while copying file to document \(error)")
                    }
                }
            }
            
        }
        
    }
    
    /// Reset the DNS plist file
    func resetPlist() {
        do {
            try FileManager.default.removeItem(atPath: plistPathInDocument)
            preparePlistForUse()
            self.load(from: self.plistPathInDocument)
        }catch{
            fatalError("Error occurred while removing file \(error)")
        }
    }
    
    /// Adds a new server to the dnsList object
    /// - Parameters:
    ///   - name:  The name for the DNS.
    ///   - ips:  The IP addresses of the DNS.
    func addNewServerWithName(_ name: String,
                              andIPs ips: [String]) {
        self.removeServer(name: name)
        self.dnsList.append([name: ips])
        self.updatePlist()
    }
    
    /// Removes a server from the dnsList object
    /// - Parameters:
    ///   - name:  The name for the DNS.
    func removeServer(name: String) {
        self.dnsList = self.dnsList.filter({
            for (key, _) in $0 {
                return key != name
            }
            return false
        })
        self.updatePlist()
    }
    
    /// Returns the value of the first key of the array of DNS
    /// - Returns:
    ///   - key: The firt key
    func firstKey() -> String? {
        
        if let firstDictionary = self.dnsList.first,
            let firstEntry = firstDictionary.first {
            return firstEntry.key
        }
        
        return nil
        
    }
    
    /// Returns the array of servers for the given key
    /// - Returns:
    ///   - ips: The array of IPs
    func valueForKey(_ key: String) -> [String] {
        for dns in self.dnsList {
            for (theKey, value) in dns {
                if theKey == key {
                    return value
                }
            }
        }
        return []
    }
    
    /// Returns the description of the key
    /// - Returns:
    ///   - description: The description of the key or how the key should be displayed
    func descriptionForKey(_ key: String) -> String {
        for dns in self.dnsList {
            for (theKey, value) in dns {
                if theKey == key {
                    if key == DNSList.CUSTOM_DNS_KEY { //L10n.Global.custom
                        switch value.count {
                        case 0:
                            return L10n.Settings.Dns.custom
                        case 1:
                            return L10n.Settings.Dns.custom + " (" + value.first! + ")"
                        default:
                            return L10n.Settings.Dns.custom + " (" + value.first! + " / " + value.last! + ")"
                        }
                    }
                    return key
                }
            }
        }
        return L10n.Settings.Dns.custom
    }
    
    /// Updates the content of the dnsList object into the plist
    private func updatePlist() {
        (self.dnsList as NSArray).write(toFile: self.plistPathInDocument,
                                        atomically: true)
    }
    
}
