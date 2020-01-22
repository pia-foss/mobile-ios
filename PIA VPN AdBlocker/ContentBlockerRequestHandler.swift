//
//  ContentBlockerRequestHandler.swift
//  PIA VPN AdBlocker
//
//  Created by Davide De Rosa on 2/21/18.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    private let webRulesURL = "https://www.privateinternetaccess.com/api/client/ios-adblocker"

    private let uti = "public.json"

    private let fallbackName = "fallback"

    func beginRequest(with context: NSExtensionContext) {
        let attachment: NSItemProvider

        let rulesURL = URL(string: webRulesURL)!
        if let webRules = try? String(contentsOf: rulesURL, encoding: .utf8) {
            attachment = NSItemProvider(item: webRules as NSString, typeIdentifier: uti)
        } else {
            attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: fallbackName, withExtension: "json"))!
        }
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
}
