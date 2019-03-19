//
//  TodayViewController.swift
//  PIAWidget
//
//  Created by Jose Antonio Blaya Garcia on 18/03/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
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
