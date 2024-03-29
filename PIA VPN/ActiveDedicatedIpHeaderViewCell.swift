//
//  ActiveDedicatedIpHeaderViewCell.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 29/1/21.
//  Copyright © 2021 Private Internet Access, Inc.
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

class ActiveDedicatedIpHeaderViewCell: UITableViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.title.text = L10n.Localizable.Dedicated.Ip.title
        self.subtitle.text = L10n.Localizable.Dedicated.Ip.Limit.title
    }

    func setup() {
        viewShouldRestyle()
    }
    // MARK: Restylable
    
    func viewShouldRestyle() {
        Theme.current.applySecondaryBackground(self)
        title.style(style: Theme.current.palette.appearance == .dark ? TextStyle.textStyle22 : TextStyle.textStyle23)
        subtitle.style(style: TextStyle.textStyle8)
    }
    
}
