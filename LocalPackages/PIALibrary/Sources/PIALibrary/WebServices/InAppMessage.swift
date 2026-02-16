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

public enum InAppMessageType {
    case none
    case action
    case view
    case link
}

public enum InAppMessageLevel {
    case system
    case api
}

public struct InAppMessage {
    
    public let id: String
    public let message: [String: String]
    public let linkMessage: [String: String]?
    public let type: InAppMessageType
    public let level: InAppMessageLevel

    public let settingAction: [String: Bool]?
    public let settingView: String?
    public let settingLink: String?
    public let executionCompletionHandler: (() -> ())?
        
    public init(withMessage message: [String: String], id: String, link: [String: String], type: InAppMessageType, level: InAppMessageLevel, actions: [String:Bool]?, view: String?, uri: String?, executionCompletionHandler: (() -> ())? = nil) {
        self.id = id
        self.message = message
        self.linkMessage = link
        self.type = type
        self.level = level
        self.settingAction = actions
        self.settingView = view
        self.settingLink = uri
        self.executionCompletionHandler = executionCompletionHandler
    }
    
}
