//
//  GlossToken.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 28/11/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

class GlossToken: GlossParser {
    let parsed: String
    
    required init?(json: JSON) {
        let token: String? = "token" <~~ json
        parsed = token ?? ""
    }
}
