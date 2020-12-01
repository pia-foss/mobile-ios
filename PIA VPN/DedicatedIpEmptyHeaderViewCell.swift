//
//  DedicatedIpEmptyHeaderViewCell.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 13/10/2020.
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
import PIALibrary

class DedicatedIpEmptyHeaderViewCell: UITableViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var activateView: UIView!
    @IBOutlet private weak var addTokenButton: PIAButton!
    @IBOutlet private weak var addTokenTextfield: UITextField!
    
    private weak var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.title.text = L10n.Dedicated.Ip.title
        self.subtitle.text = L10n.Dedicated.Ip.Activation.description
        self.addTokenTextfield.accessibilityLabel = L10n.Dedicated.Ip.Token.Textfield.accessibility
        self.addTokenTextfield.placeholder = L10n.Dedicated.Ip.Token.Textfield.placeholder
        self.addTokenTextfield.delegate = self
    }

    func setup(withTableView tableView: UITableView) {
        self.tableView = tableView
        styleButton()
        styleContainer()
        viewShouldRestyle()
    }
    // MARK: Restylable
    
    private func styleContainer() {
        activateView.layer.cornerRadius = 6.0
        activateView.layer.borderWidth = 0.5
        activateView.layer.borderColor = UIColor.piaGrey4.cgColor
    }

    private func styleButton() {
        addTokenButton.setRounded()
        addTokenButton.style(style: TextStyle.Buttons.piaGreenButton)
        addTokenButton.setTitle(L10n.Dedicated.Ip.Activate.Button.title,
                               for: [])
    }

    func viewShouldRestyle() {
        Theme.current.applyClearTextfield(addTokenTextfield)
        Theme.current.applyPrincipalBackground(activateView)
        Theme.current.applySecondaryBackground(self)
        title.style(style: Theme.current.palette.appearance == .dark ? TextStyle.textStyle22 : TextStyle.textStyle23)
        subtitle.style(style: TextStyle.textStyle8)
    }
    
    @IBAction private func activateToken() {
        if let token = addTokenTextfield.text, !token.isEmpty {
            NotificationCenter.default.post(name: .DedicatedIpShowAnimation, object: nil)
            Client.providers.serverProvider.activateDIPToken(token) { [weak self] (server, error) in
                NotificationCenter.default.post(name: .DedicatedIpHideAnimation, object: nil)
                self?.addTokenTextfield.text = ""
                guard let dipServer = server else {
                    Macros.displayStickyNote(withMessage: L10n.Dedicated.Ip.Message.Invalid.token,
                                             andImage: Asset.iconWarning.image)
                    return
                }
                switch dipServer?.dipStatus {
                case .active:
                    Macros.displaySuccessImageNote(withImage: Asset.iconWarning.image, message: L10n.Dedicated.Ip.Message.Valid.token)
                    
                    guard let token = dipServer?.dipToken, let address = dipServer?.bestAddress() else {
                        return
                    }
                        
                    if let expiringDate = dipServer?.dipExpire, let substractedDate = expiringDate.removing(days: 5) {
                        if Calendar.current.isDateInToday(substractedDate) {
                            //Expiring in 5 days
                            let message = InAppMessage(withMessage: ["en": L10n.Dedicated.Ip.Message.Token.willexpire], id: token, link: ["en": L10n.Dedicated.Ip.Message.Token.Willexpire.link], type: .link, level: .system, actions: nil, view: nil, uri: AppConstants.Web.homeURL.absoluteString)
                            MessagesManager.shared.postSystemMessage(message: message)
                        }
                    }
                    
                    var relation = AppPreferences.shared.dedicatedTokenIPReleation
                    if relation.isEmpty {
                        //no data
                        relation[token] = address.ip
                    } else {
                        if relation[token] != address.ip {
                            //changes
                            relation[token] = address.ip
                            let message = InAppMessage(withMessage: ["en": L10n.Dedicated.Ip.Message.Ip.updated], id: token, link: ["en":""], type: .none, level: .system, actions: nil, view: nil, uri: nil)
                            MessagesManager.shared.postSystemMessage(message: message)
                        }
                    }
                    AppPreferences.shared.dedicatedTokenIPReleation[token] = address.ip

                case .expired:
                    Macros.displayWarningImageNote(withImage: Asset.iconWarning.image, message: L10n.Dedicated.Ip.Message.Expired.token)
                case .error:
                    Macros.displayWarningImageNote(withImage: Asset.iconWarning.image, message: L10n.Dedicated.Ip.Message.Error.token)
                default:
                    Macros.displayStickyNote(withMessage: L10n.Dedicated.Ip.Message.Invalid.token,
                                             andImage: Asset.iconWarning.image)
                }
                NotificationCenter.default.post(name: .DedicatedIpReload, object: nil)
                NotificationCenter.default.post(name: .PIAThemeDidChange, object: nil)
            }
        } else {
            Macros.displayStickyNote(withMessage: L10n.Dedicated.Ip.Message.Incorrect.token,
                                     andImage: Asset.iconWarning.image)
        }
    }

}

extension DedicatedIpEmptyHeaderViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tableView.endEditing(true)
        tableView.reloadData()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activateView.layer.borderColor = Theme.current.palette.emphasis.cgColor
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        activateView.layer.borderColor = UIColor.piaGrey4.cgColor
        return true
    }
    
}
