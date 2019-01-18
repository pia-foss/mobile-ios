//
//  Usage.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation

public struct Usage {
    
    public let uploaded: UInt64
    public let downloaded: UInt64
    
    init(uploaded: UInt64, downloaded: UInt64) {
        self.uploaded = uploaded
        self.downloaded = downloaded
    }
    
}
