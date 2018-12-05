//
//  MenuItemCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class MenuItemCell: UITableViewCell, Restylable {
    @IBOutlet private weak var imvIcon: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!
    
    func fill(withTitle title: String, icon: UIImage?) {
        viewShouldRestyle()
        
        labelTitle.text = title
        imvIcon.image = icon
    }

    // MARK: Restylable
    
    func viewShouldRestyle() {
        Theme.current.applyMenuBackground(self)
        Theme.current.applyMenuListStyle(labelTitle)
    }
}
