//
//  GlossParser.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/11/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

protocol GlossParser: JSONDecodable {
    associatedtype T
    
    var parsed: T { get }
}
