//
//  MessagesTile.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 11/11/2020.
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

class MessagesTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet {
            statusUpdated()
        }
    }

    @IBOutlet private weak var messageTextView: UITextView!
    @IBOutlet private weak var alertIcon: UIImageView!
    @IBOutlet private weak var dismissButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
        self.setupView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)

        viewShouldRestyle()
        self.alertIcon.image = Asset.iconAlert.image.withRenderingMode(.alwaysTemplate)
    
        if let message = MessagesManager.shared.availableMessage(), let _ = message.linkMessage {
            let tap = UITapGestureRecognizer(target: self, action: #selector(openLink))
            messageTextView.addGestureRecognizer(tap)
        }

    }
    
    @objc private func openLink() {
        if let message = MessagesManager.shared.availableMessage() {
            message.executeAction()
        }
    }
    
    @IBAction private func dismiss(_ sender: AnyObject) {
        if let message = MessagesManager.shared.availableMessage() {
            MessagesManager.shared.dismiss(message: message.id)
            Macros.postNotification(.PIAUpdateFixedTiles)
        }
    }
    
    @objc private func viewShouldRestyle() {
        Theme.current.applyMessagesBackground(self)
        if let message = MessagesManager.shared.availableMessage() {
            self.messageTextView.attributedText = Theme.current.messageWithLinkText(
                withMessage: message.localisedMessage(),
                link: "killswitch"
            )
            self.messageTextView.textAlignment = .left
            if message.level == .api {
                self.alertIcon.tintColor = UIColor.piaGreen
                Theme.current.applyMessageLinkAttributes(messageTextView, withColor: UIColor.piaGreen)
            } else {
                self.alertIcon.tintColor = UIColor.piaOrange
                Theme.current.applyMessageLinkAttributes(messageTextView, withColor: UIColor.piaOrange)
            }
        }
    }

    private func statusUpdated() {
    }
    
}
