//
//  RegionCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class RegionCell: UITableViewCell, Restylable {
    @IBOutlet private weak var imvFlag: UIImageView!

    @IBOutlet private weak var labelRegion: UILabel!
    
    @IBOutlet private weak var labelPingTime: UILabel!

    func fill(withServer server: Server, isSelected: Bool) {
        viewShouldRestyle()

        imvFlag.setImage(fromServer: server)
        labelRegion.text = server.name
        
        var pingTimeString: String?
        if let pingTime = server.pingTime {
            pingTimeString = "\(pingTime)ms"

            Theme.current.applyPingTime(labelPingTime, time: pingTime)
        }
        labelPingTime.text = pingTimeString
        
        accessoryView?.isHidden = !isSelected
        
        if let pingTimeString = pingTimeString {
            accessibilityLabel = "\(server.name), \(pingTimeString)"
        } else {
            accessibilityLabel = server.name
        }
        accessibilityIdentifier = "uitests.regions.region_name"
    }

    // MARK: Restylable

    func viewShouldRestyle() {
        backgroundView = UIView()
        selectedBackgroundView = UIView()
        accessoryView = UIImageView(image: Asset.accessorySelected.image)
        
        Theme.current.applySolidLightBackground(backgroundView!)
        Theme.current.applySelection(selectedBackgroundView!)
        Theme.current.applyList(labelRegion, appearance: .dark)
        Theme.current.applyTag(labelPingTime, appearance: .dark)
    }
}
