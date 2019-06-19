//
//  GlossProduct.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 11/04/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

extension Product: Glossy {

    public init?(json: JSON) {
        
        let plan: Plan = "plan" <~~ json ?? .other
        
        guard let price: String = "price" <~~ json else {
            return nil
        }
        guard let legacy: Bool = "legacy" <~~ json else {
            return nil
        }
        guard let identifier: String = "id" <~~ json else {
            return nil
        }
        
        self.identifier = identifier
        self.plan = plan
        self.price = price
        self.legacy = legacy
        
    }
    
    public func toJSON() -> JSON? {
        
        return jsonify([
            "id" ~~> identifier,
            "price" ~~> price,
            "legacy" ~~> legacy,
            "plan" ~~> plan
            ])
    }
}
