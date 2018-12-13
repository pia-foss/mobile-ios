//
//  AutolayoutViewController+Styles.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 13/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

extension AutolayoutViewController {
    
    func styleNavigationBarWithTitle(_ title: String) {
        
        let currentStatus = Client.providers.vpnProvider.vpnStatus
        
        switch currentStatus {
        case .connected:
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: TextStyle.textStyle6)
            titleLabelView.text = title
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: .white,
                                                   andBarTintColors: [UIColor.piaGreen,
                                                                      UIColor.piaGreenDark20])
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()
            
        default:
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: Theme.current.palette.appearance == .dark ?
                TextStyle.textStyle6 :
                TextStyle.textStyle7)
            titleLabelView.text = title
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: nil,
                                                   andBarTintColors: nil)
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()
            
        }
    }

}
