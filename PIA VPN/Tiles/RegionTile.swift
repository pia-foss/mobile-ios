//
//  RegionTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
//  Copyright © 2020 Private Internet Access, Inc.
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
import PIALibrary

class RegionTile: UIView, Tileable {
    
    private let defaultLeadingDistance: CGFloat = 25
    private let geoLeadingDistance: CGFloat = 49
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet {
            statusUpdated()
        }
    }
    
    @IBOutlet private weak var labelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var tileTitle: UILabel!
    @IBOutlet private weak var serverName: UILabel!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var geoImageView: UIImageView!
    private var greenDot: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
        self.setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func hasDetailView() -> Bool {
        return true
    }
    
    private func setupView() {
        
        self.detailSegueIdentifier = StoryboardSegue.Main.selectRegionSegueIdentifier.rawValue
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateServer), name: .PIAServerHasBeenUpdated, object: nil)

        viewShouldRestyle()
        self.tileTitle.text = L10n.Tiles.Region.title.uppercased()
        self.updateServer()
    }
    
    @objc private func updateServer() {
        
        greenDot?.removeFromSuperview()
        
        let effectiveServer = Client.preferences.displayedServer
        let vpn = Client.providers.vpnProvider
        self.serverName.text = effectiveServer.name(forStatus: vpn.vpnStatus)
        self.mapImageView.image = Theme.current.mapImage()

        setupRegionTileAndMapForServer(effectiveServer)

        self.mapImageView.addSubview(greenDot)
        

    }
    
    private func setupRegionTileAndMapForServer(_ server: Server) {
        let coordFinder = CoordinatesFinder(forServer: server.name, usingMapImage: self.mapImageView)
        greenDot = coordFinder.dot()
        self.geoImageView.isHidden = !server.geo
        self.labelLeadingConstraint.constant = server.geo ? geoLeadingDistance : defaultLeadingDistance
    }
    
    @objc private func viewShouldRestyle() {
        updateServer()
        tileTitle.style(style: TextStyle.textStyle21)
        Theme.current.applyPrincipalBackground(self)
        Theme.current.applySettingsCellTitle(serverName, appearance: .dark)
    }
    
    private func statusUpdated() {
    }
    
}
