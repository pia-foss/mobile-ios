//
//  NetworkCollectionViewCell.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 04/08/2020.
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

class NetworkCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var statusColor: UIImageView!
    @IBOutlet private weak var networkIconBackground: UIImageView!
    @IBOutlet private weak var networkIcon: UIImageView!
    @IBOutlet private weak var manageButton: UIButton!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    private var popover: Popover!
    override var isSelected: Bool {
        didSet {
            if isSelected {
                showOptions()
            }
        }
    }

    var data: Rule? {
        didSet {
            guard let data = data else { return }
            switch data.type {
            case .openWiFi:
                title.text = L10n.Network.Management.Tool.Open.wifi
                switch data.rule {
                case .alwaysConnect:
                    networkIcon.image = Asset.Piax.Nmt.iconOpenWifiConnect.image
                case .alwaysDisconnect:
                    networkIcon.image = Asset.Piax.Nmt.iconOpenWifiDisconnect.image
                case .retainState:
                    networkIcon.image = Asset.Piax.Nmt.iconOpenWifiRetain.image
                }
            case .protectedWiFi:
                title.text = L10n.Network.Management.Tool.Secure.wifi
                switch data.rule {
                case .alwaysConnect:
                    networkIcon.image = Asset.Piax.Nmt.iconSecureWifiConnect.image
                case .alwaysDisconnect:
                    networkIcon.image = Asset.Piax.Nmt.iconSecureWifiDisconnect.image
                case .retainState:
                    networkIcon.image = Asset.Piax.Nmt.iconSecureWifiRetain.image
                }
            case .cellular:
                title.text = L10n.Network.Management.Tool.Mobile.data
                switch data.rule {
                case .alwaysConnect:
                    networkIcon.image = Asset.Piax.Nmt.iconMobileDataConnect.image
                case .alwaysDisconnect:
                    networkIcon.image = Asset.Piax.Nmt.iconMobileDataDisconnect.image
                case .retainState:
                    networkIcon.image = Asset.Piax.Nmt.iconMobileDataRetain.image
                }
            case .trustedNetwork:
                title.text = data.ssid
                switch data.rule {
                case .alwaysConnect:
                    networkIcon.image = Asset.Piax.Nmt.iconCustomWifiConnect.image
                case .alwaysDisconnect:
                    networkIcon.image = Asset.Piax.Nmt.iconCustomWifiDisconnect.image
                case .retainState:
                    networkIcon.image = Asset.Piax.Nmt.iconCustomWifiRetain.image
                }
            }
            
            switch data.rule {
            case .alwaysConnect:
                subtitle.text = L10n.Network.Management.Tool.Always.connect
                statusColor.backgroundColor = UIColor.piaNMTGreen
            case .alwaysDisconnect:
                subtitle.text = L10n.Network.Management.Tool.Always.disconnect
                statusColor.backgroundColor = UIColor.piaNMTRed
            case .retainState:
                subtitle.text = L10n.Network.Management.Tool.Retain.state
                statusColor.backgroundColor = UIColor.piaNMTBlue
            }
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        networkIconBackground.layer.cornerRadius = 10
        networkIconBackground.backgroundColor = UIColor.piaNMTGrey
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
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
    
    @IBAction func showOptions() {
        
        guard let data = data else { return }

        let width = self.contentView.frame.width * 1.5
        let height = 44 * (data.type == NMTType.trustedNetwork ? 4 : 3) //Default height * 3 or 4 options
        let optionsView = NetworkRuleOptionView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
        optionsView.currentType = data.type
        optionsView.currentPopover = popover
        optionsView.ssid = data.ssid
        popover.show(optionsView, fromView: self.manageButton)
    }

    // MARK: Restylable

    func viewShouldRestyle() {
        
        title.style(style: Theme.current.palette.appearance == .dark ? TextStyle.textStyleCardTitleDark : TextStyle.textStyleCardTitleLight)
        subtitle.style(style: TextStyle.textStyle8)
        let optionsImage = Asset.Piax.Nmt.iconOptions.image.withRenderingMode(.alwaysTemplate)
        manageButton.setImage(optionsImage, for: .normal)
        manageButton.tintColor = Theme.current.palette.appearance == .dark ? UIColor.white : UIColor.piaGrey6
        
        popover.dismiss()
    }
}
