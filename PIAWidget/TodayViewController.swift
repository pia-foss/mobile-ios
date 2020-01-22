//
//  TodayViewController.swift
//  PIAWidget
//
//  Created by Jose Antonio Blaya Garcia on 18/03/2019.
//  Copyright © 2020 Private Internet Access Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.

//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    private let vpnStatus = "vpn.status"
    private let vpnButtonDescription = "vpn.button.description"
    private let appGroup = "group.com.privateinternetaccess"
    private let urlSchema = "privateinternetaccess://"

    @IBOutlet weak var widgetConnectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sharedDefaults = UserDefaults(suiteName: appGroup),
            let buttonTitle = sharedDefaults.string(forKey: vpnButtonDescription) {
            widgetConnectButton.setTitle(buttonTitle.uppercased(), for: [])
        }
        
        widgetConnectButton.layer.cornerRadius = 6.0
        widgetConnectButton.clipsToBounds = true
        widgetConnectButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        widgetConnectButton.setTitleColor(UIColor.white, for: [])
        widgetConnectButton.backgroundColor = UIColor(red: 76.0 / 255.0, green: 182.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
        widgetConnectButton.layer.borderWidth = 0
        widgetConnectButton.layer.borderColor = UIColor.clear.cgColor

    }
    
    @IBAction func widgetButtonClicked(_ sender: Any) {
        if let sharedDefaults = UserDefaults(suiteName: appGroup),
            let status = sharedDefaults.string(forKey: vpnStatus),
            let appURL = URL(string: urlSchema+status) {
            extensionContext?.open(appURL, completionHandler: nil)
        }
    }
}
