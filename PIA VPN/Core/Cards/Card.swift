//
//  Card.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 09/07/2020.
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

import UIKit

class Card: Collectable {
    
    var version: String
    
    var title: String
    var description: String
    var cardImage: ImageAsset
    var cardFrontImage: ImageAsset
    var ctaLabel: String
    var cta: CTAFunc
    var learnMoreLink: URL?
    
    private(set) var showCTA = true

    init(_ version: String, _ title: String, _ description: String, _ cardImage: ImageAsset, _ cardFrontImage: ImageAsset, _ ctaLabel: String, _ learnMoreLink: URL? = nil, _ cta: @escaping CTAFunc ) {
        self.version = version
        self.title = title
        self.description = description
        self.cardImage = cardImage
        self.cardFrontImage = cardFrontImage
        self.ctaLabel = ctaLabel
        self.cta = cta
        if let link = learnMoreLink {
            self.learnMoreLink = link
        }
    }
    
    func hideCTA() {
        self.showCTA = false
    }
    
}
