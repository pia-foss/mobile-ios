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

protocol DedicatedIpEmptyHeaderViewCellDelegate: AnyObject {
    func handleDIPActivation(with token: String, cell: DedicatedIpEmptyHeaderViewCell)
}

class DedicatedIpEmptyHeaderViewCell: UITableViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var activateView: UIView!
    @IBOutlet private weak var addTokenButton: PIAButton!
    @IBOutlet private weak var addTokenTextfield: UITextField!
    
    private weak var tableView: UITableView!
    weak var delegate: DedicatedIpEmptyHeaderViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.title.text = L10n.Dedicated.Ip.title
        self.subtitle.text = L10n.Dedicated.Ip.Activation.description
        self.addTokenTextfield.accessibilityLabel = L10n.Dedicated.Ip.Token.Textfield.accessibility
        self.addTokenTextfield.placeholder = L10n.Dedicated.Ip.Token.Textfield.placeholder
        self.addTokenTextfield.delegate = self
    }

    func setup(withTableView tableView: UITableView, delegate: DedicatedIpEmptyHeaderViewCellDelegate) {
        self.tableView = tableView
        self.delegate = delegate
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
        if let token = addTokenTextfield.text {
            self.delegate?.handleDIPActivation(with: token, cell: self)
        }
    }
    
    func emptyTokenTextField() {
        addTokenTextfield.text = ""
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
