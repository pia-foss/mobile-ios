//
//  InAppMessage.swift
//  PIALibrary
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
import PIAAccount

public enum InAppMessageType {
    case action
    case view
    case link
}

public struct InAppMessage {
    
    private let message: [String: String]
    private let linkMessage: [String: String]
    private let type: InAppMessageType
    
    private let settingAction: [String: Bool]?
    private let settingView: String?
    private let settingLink: String?
    
    init(withMessage messageInformation: MessagesInformation.Message) {
        
        self.message = messageInformation.message
        self.linkMessage = messageInformation.link.text
        
        if !messageInformation.link.action.settings.isEmpty {
            self.type = .action
            var actions = [String: Bool]()
            for setting in messageInformation.link.action.settings {
                actions[setting.key] = setting.value.boolValue
            }
            self.settingAction = actions
            self.settingLink = nil
            self.settingView = nil
        } else if !messageInformation.link.action.uri.isEmpty {
            self.type = .link
            self.settingLink = messageInformation.link.action.uri
            self.settingAction = nil
            self.settingView = nil
        } else {
            self.type = .view
            self.settingView = messageInformation.link.action.view
            self.settingLink = nil
            self.settingAction = nil
        }
        
    }
    
}
