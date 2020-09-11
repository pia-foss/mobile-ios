//
//  RegionData.swift
//  PIALibrary
//  
//  Created by Jose Blaya on 26/08/2020.
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

/// Static data retrieved from the server for localization and gps coordinates
public struct RegionData {
    
    private let translations: [String: [String: String]]
    private let geolocations: [String: [String]]
    
    private let defaultCoordinates = ["40.463667", "-3.74922"]

    init(translations: [String: [String: String]], geolocations: [String: [String]]) {
        self.translations = translations
        self.geolocations = geolocations
    }
    
}

///Utilities
public extension RegionData {
    
    public func geolocation(forIdentifier identifier: String) -> [String] {
        return self.geolocations[identifier] ?? defaultCoordinates
    }
    
    public func localisedServerName(forCountryName countryName: String) -> String {
        
        if let localizationData = self.translations[countryName],
            let translatedServerName = localizationData[Locale.current.identifier.replacingOccurrences(of: "_", with: "-")],
            !translatedServerName.isEmpty {
            return translatedServerName
        } else { //Not found, let's try to find it without the region
            if let localizationData = self.translations[countryName],
                let locale = Locale.current.identifier.split(separator: "_").first,
                let translatedServerName = localizationData[locale.description],
                !translatedServerName.isEmpty {
                return translatedServerName
            } else { //Not found, let's try to find a key with the same code
                if let localizationData = self.translations[countryName],
                    let locale = Locale.current.identifier.split(separator: "_").first,
                    let keyThatMatch = localizationData.keys.filter( { $0.starts(with: locale.description)} ).first,
                    let translatedServerName = localizationData[keyThatMatch],
                    !translatedServerName.isEmpty {
                    return translatedServerName
                }
            }
        }
        
        return countryName
        
    }

}
