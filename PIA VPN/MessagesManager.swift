//
//  MessagesManager.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 10/11/2020.
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
import PIALibrary
import PIAAccount

public class MessagesManager: NSObject {

    public static let shared = MessagesManager()
    private var apiMessage: InAppMessage!
    private var systemMessage: InAppMessage!

    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(presentExpiringDIPRegionSystemMessage(notification:)), name: .PIADIPRegionExpiring, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func refreshMessages() {
        
        if !AppPreferences.shared.stopInAppMessages {
            Client.providers.accountProvider.inAppMessages(forAppVersion: Macros.localizedVersionNumber()) { (message, error) in
                if let message = message, !message.wasDismissed() {
                    self.apiMessage = message
                    Macros.postNotification(.PIAUpdateFixedTiles)
                }
            }
        }
    }
    
    func postSystemMessage(message: InAppMessage) {
        self.systemMessage = message
        Macros.postNotification(.PIAUpdateFixedTiles)
    }
    
    func availableMessage() -> InAppMessage? {
        
        if let message = updateMessages() {
            return message
        }
        
        if let message = systemMessages() {
            return message
        }
        
        return apiMessage
        
    }
    
    func dismiss(message id: String) {
        AppPreferences.shared.dismissedMessages.append(id)
        if apiMessage != nil, id == apiMessage.id {
            apiMessage = nil
        } else if id == systemMessage.id {
            systemMessage = nil
        }
    }
    
    func reset() {
        self.apiMessage = nil
        self.systemMessage = nil
    }
    
    private func updateMessages() -> InAppMessage? {
        return nil
    }
    
    private func systemMessages() -> InAppMessage? {
        return self.systemMessage
    }

}

private extension InAppMessage {
    
    func wasDismissed() -> Bool {
        return AppPreferences.shared.dismissedMessages.contains(self.id)
    }
}

extension InAppMessage {
    
    func executeAction() {
        
        var command: Command? = nil
        
        switch type {
        case .link:
            if let link = self.settingLink {
                command = LinkCommand(link)
            }
        case .view:
            if let view = self.settingView {
                command = ViewCommand(view)
            }
        case .action:
            if let actions = self.settingAction {
                command = ActionCommand(actions)
            }
        default:
            break
        }

        command?.execute()
        
    }
    
    func localisedMessage() -> String {
        
        return searchIn(dictionary: self.message)
                
    }
    
    func localisedLink() -> String {
        
        if let linkMessage = self.linkMessage {
            return searchIn(dictionary: linkMessage)
        }
        return ""
                
    }

    private func searchIn(dictionary: [String: String]) -> String {
        
        if let translatedMessaged = dictionary[Locale.current.identifier.replacingOccurrences(of: "_", with: "-")],
            !translatedMessaged.isEmpty {
            return translatedMessaged
        } else { //Not found, let's try to find it without the region
            if let locale = Locale.current.identifier.split(separator: "_").first,
                let translatedMessaged = dictionary[locale.description],
                !translatedMessaged.isEmpty {
                return translatedMessaged
            } else { //Not found, let's try to find a key with the same code
                if let locale = Locale.current.identifier.split(separator: "_").first,
                    let keyThatMatch = dictionary.keys.filter( { $0.starts(with: locale.description)} ).first,
                    let translatedMessaged = dictionary[keyThatMatch],
                    !translatedMessaged.isEmpty {
                    return translatedMessaged
                }
            }
        }

        return dictionary["en-US"] ?? ""

    }
    
}

extension MessagesManager {
    
    @objc private func presentExpiringDIPRegionSystemMessage(notification: Notification) {

        if let userInfo = notification.userInfo, let token = userInfo[NotificationKey.token] as? String {
            let message = InAppMessage(withMessage: ["en": L10n.Dedicated.Ip.Message.Token.willexpire], id: token, link: ["en": L10n.Dedicated.Ip.Message.Token.Willexpire.link], type: .link, level: .system, actions: nil, view: nil, uri: AppConstants.Web.homeURL.absoluteString)
            MessagesManager.shared.postSystemMessage(message: message)
        }

    }
}
