//
//  ContentBlockerRequestHandler.swift
//  PIA VPN AdBlocker
//
//  Created by Davide De Rosa on 2/21/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
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
