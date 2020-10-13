//
//  DedicatedIpEmptyHeaderCollectionViewCell.swift
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

class DedicatedIpEmptyHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var activateView: UIView!
    @IBOutlet private weak var addTokenButton: PIAButton!
    @IBOutlet private weak var addTokenTextfield: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.title.text = "Dedicated IP"
        self.subtitle.text = "Activate your Dedicated IP pasting your token in the form below. If you've recently purchased a dedicated IP, you can generate the token by going to the PIA website."
        self.addTokenTextfield.placeholder = "Paste in your token here"
        self.addTokenTextfield.delegate = self
    }

    func setup() {
        styleButton()
        styleContainer()
        viewShouldRestyle()
    }
    // MARK: Restylable
    
    private func styleContainer() {
        activateView.layer.cornerRadius = 6.0
    }

    private func styleButton() {
        addTokenButton.setRounded()
        addTokenButton.style(style: TextStyle.Buttons.piaGreenButton)
        addTokenButton.setTitle("Activate",
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
        NotificationCenter.default.post(name: .DedicatedIpReload, object: nil)
    }

}

extension DedicatedIpEmptyHeaderCollectionViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
