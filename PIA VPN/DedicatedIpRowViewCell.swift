//
//  DedicatedIpRowCollectionViewCell.swift
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

class DedicatedIpRowViewCell: UITableViewCell, Restylable {

    @IBOutlet private weak var imvFlag: UIImageView!

    @IBOutlet private weak var labelRegion: UILabel!

    @IBOutlet private weak var labelIp: UILabel!

    private weak var server: Server!

    func fill(withServer server: Server) {
        
        viewShouldRestyle()
        self.server = server

        imvFlag.setImage(fromServer: server)
        imvFlag.accessibilityLabel = L10n.Dedicated.Ip.Country.Flag.accessibility(server.name)
        labelRegion.text = server.name
        
        if let pingAddress = server.bestAddress() {
            labelIp.text = pingAddress.ip
            labelIp.accessibilityLabel = pingAddress.ip
        }

    }
    
    // MARK: Restylable

    func viewShouldRestyle() {
        
        Theme.current.applyRegionSolidLightBackground(self)
        Theme.current.applyRegionSolidLightBackground(self.contentView)

        Theme.current.applySettingsCellTitle(labelRegion, appearance: .dark)
        Theme.current.applySettingsCellTitle(labelIp, appearance: .dark)
                
    }


}
