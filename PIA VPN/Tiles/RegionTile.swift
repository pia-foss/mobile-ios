//
//  RegionTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 11/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class RegionTile: UIView, Tileable {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet {
            statusUpdated()
        }
    }
    
    @IBOutlet private weak var tileTitle: UILabel!
    @IBOutlet private weak var serverName: UILabel!
    @IBOutlet private weak var mapImageView: UIImageView!

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
        let effectiveServer = Client.providers.vpnProvider.profileServer ?? Client.providers.serverProvider.targetServer
        let vpn = Client.providers.vpnProvider
        self.serverName.text = effectiveServer.name(forStatus: vpn.vpnStatus)
        self.mapImageView.image = UIImage(named: Theme.current.mapImageByServerName(effectiveServer.name))
    }
    
    @objc private func viewShouldRestyle() {
        updateServer()
        tileTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySolidLightBackground(self)
        Theme.current.applySettingsCellTitle(serverName, appearance: .dark)
    }
    
    private func statusUpdated() {
    }
    
}
