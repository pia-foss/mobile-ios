//
//  QuickConnectTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 10/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class QuickConnectTile: UIView, Tileable {

    var detailViewAction: Func!
    var view: UIView!
    var detailSegueIdentifier: String!
    
    @IBOutlet private weak var tileTitle: UILabel!
    @IBOutlet private weak var stackView: UIStackView!

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
    
    private func setupView() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateQuickConnectList), name: .PIAServerHasBeenUpdated, object: nil)
        
        viewShouldRestyle()
        self.detailViewAction = {}
        self.tileTitle.text = L10n.Tiles.Quick.Connect.title.uppercased()
        updateQuickConnectList()
        
    }
    
    @objc private func viewShouldRestyle() {
        tileTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySolidLightBackground(self)
    }
    
    @objc private func updateQuickConnectList() {
        let historicalServers = Client.providers.serverProvider.historicalServers
        for containerView in stackView.subviews {
            if let button = containerView.subviews.first as? ServerButton,
                let favoriteImage = containerView.subviews.last as? UIImageView {
                button.setImage(Asset.Flags.flagUniversal.image, for: .normal)
                button.alpha = 0.1
                button.imageView?.contentMode = .scaleAspectFit
                button.isUserInteractionEnabled = false
                favoriteImage.isHidden = true
            }
        }
        for (index, server) in historicalServers.enumerated().reversed()  {
            let buttonIndex = historicalServers.count - (index + 1)
            let view = stackView.subviews[buttonIndex]
            if let button = view.subviews.first as? ServerButton,
                let favoriteImage = view.subviews.last as? UIImageView {
                button.alpha = 1
                button.setImage(fromServer: server)
                button.imageView?.contentMode = .scaleAspectFit
                button.isUserInteractionEnabled = true
                button.server = server
                favoriteImage.isHidden = !AppPreferences.shared.favoriteServerIdentifiers.contains(server.identifier)
            }
        }
    }
    
    @IBAction private func connectToServer(_ sender: ServerButton) {
        if let server = sender.server {
            let currentServer = Client.preferences.displayedServer
            guard (server.identifier != currentServer.identifier) else {
                return
            }
            Client.preferences.displayedServer = server
            NotificationCenter.default.post(name: .PIAThemeDidChange,
                                            object: self,
                                            userInfo: nil)
            NotificationCenter.default.post(name: .PIAServerHasBeenUpdated,
                                            object: self,
                                            userInfo: nil)
        }
    }

}
