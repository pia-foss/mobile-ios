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
import UIKit

public class MessagesManager: NSObject {

    public static let shared = MessagesManager()
    private var apiMessage: InAppMessage!
    private var systemMessage: InAppMessage!
    private static let surveyMessageID = "take-the-survey-message-banner"
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(presentExpiringDIPRegionSystemMessage(notification:)), name: .PIADIPRegionExpiring, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentIPUpdatedSystemMessage(notification:)), name: .PIADIPCheckIP, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        if id == MessagesManager.surveyMessageID {
            AppPreferences.shared.userInteractedWithSurvey = true
        }
        
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
                Macros.displaySuccessImageNote(withImage: Asset.iconWarning.image, message: L10n.Inapp.Messages.Settings.updated)
            }
        default:
            break
        }

        command?.execute()
        executionCompletionHandler?()
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
            let message = InAppMessage(withMessage: ["en-US": L10n.Dedicated.Ip.Message.Token.willexpire], id: token, link: ["en-US": L10n.Dedicated.Ip.Message.Token.Willexpire.link], type: .link, level: .system, actions: nil, view: nil, uri: AppConstants.Web.homeURL.absoluteString)
            MessagesManager.shared.postSystemMessage(message: message)
        }

    }
    
    @objc private func presentIPUpdatedSystemMessage(notification: Notification) {

        if let userInfo = notification.userInfo, let token = userInfo[NotificationKey.token] as? String, let ip = userInfo[NotificationKey.ip] as? String {
            var relation = AppPreferences.shared.dedicatedTokenIPReleation
            if relation.isEmpty {
                //no data
                relation[token] = ip
            } else {
                if relation[token] != nil && relation[token] != ip {
                    //changes
                    relation[token] = ip
                    let message = InAppMessage(withMessage: ["en-US": L10n.Dedicated.Ip.Message.Ip.updated], id: token, link: ["en-US":""], type: .none, level: .system, actions: nil, view: nil, uri: nil)
                    MessagesManager.shared.postSystemMessage(message: message)
                }
            }
            AppPreferences.shared.dedicatedTokenIPReleation[token] = ip
        }
    }
    
    
    func showInAppSurveyMessage() {
        let message = InAppMessage(withMessage: ["en-US": L10n.Account.Survey.message.appendDetailSymbol()], id: MessagesManager.surveyMessageID, link: ["en-US": L10n.Account.Survey.messageLink.appendDetailSymbol()], type: .link, level: .api, actions: nil, view: nil, uri: AppConstants.Survey.formURL.absoluteString) { [weak self] in
            self?.dismiss(message: MessagesManager.surveyMessageID)
        }
        MessagesManager.shared.postSystemMessage(message: message)
    }
}

private extension String {
    func appendDetailSymbol() -> String {
        let symbol = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? "⟨ " : " ⟩"
        return "\(self)\(symbol)"
    }
}
