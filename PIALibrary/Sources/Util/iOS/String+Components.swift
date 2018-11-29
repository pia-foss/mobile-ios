//
//  String+Components.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 28/11/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        
        return results.map { String($0) }
    }
}
