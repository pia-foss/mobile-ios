//
//  CustomNetworkCollectionViewCell.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 05/08/2020.
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
import Popover

class CustomNetworkCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var wifiIcon: UIImageView!
    @IBOutlet private weak var selectedIcon: UIImageView!
    private var popover: Popover!
    override var isSelected: Bool {
        didSet {
            selectedIcon.alpha = isSelected ? 1.0 : 0.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let options = [
          .type(.auto),
          .cornerRadius(10),
          .animationIn(0.3),
          .blackOverlayColor(UIColor.black.withAlphaComponent(0.1)),
          .arrowSize(CGSize.zero)
          ] as [PopoverOption]
        self.popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        viewShouldRestyle()
    }

    func setup(withTitle title: String) {
        self.title.text = title
    }

    func showOptions() {
        let width = self.contentView.frame.width / 1.5
        let height = 44 * 3 //Default height * 3 options
        let optionsView = NetworkRuleOptionView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
        optionsView.currentPopover = popover
        optionsView.currentType = .trustedNetwork
        optionsView.ssid = title.text!
        popover.show(optionsView, fromView: self.contentView)
    }

    // MARK: Restylable

    func viewShouldRestyle() {
        title.style(style: TextStyle.textStyle3)
        let wifiImage = Asset.Piax.Nmt.iconNmtWifi.image.withRenderingMode(.alwaysTemplate)
        wifiIcon.image = wifiImage
        wifiIcon.tintColor = .piaGrey4
        popover.dismiss()

    }

}
