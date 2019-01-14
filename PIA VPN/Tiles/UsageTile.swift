//
//  UsageTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

class UsageTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal
    
    @IBOutlet private weak var usageTitle: UILabel!
    @IBOutlet private weak var uploadTitle: UILabel!
    @IBOutlet private weak var uploadValue: UILabel!
    @IBOutlet private weak var downloadTitle: UILabel!
    @IBOutlet private weak var downloadValue: UILabel!

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
        nc.addObserver(self, selector: #selector(displayUsageInformation), name: .PIAVPNUsageUpdate, object: nil)
        
        viewShouldRestyle()
        self.usageTitle.text = L10n.Tiles.Usage.title.uppercased()
        self.uploadTitle.text = L10n.Tiles.Usage.upload
        self.downloadTitle.text = L10n.Tiles.Usage.download
        displayUsageInformation()
    }
    
    @objc private func viewShouldRestyle() {
        usageTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySettingsCellTitle(uploadValue, appearance: .dark)
        Theme.current.applySettingsCellTitle(downloadValue, appearance: .dark)
        Theme.current.applySubtitleTileUsage(uploadTitle, appearance: .dark)
        Theme.current.applySubtitleTileUsage(downloadTitle, appearance: .dark)
        Theme.current.applySolidLightBackground(self)
        displayUsageInformation()
    }
    
    @objc private func displayUsageInformation() {
        Client.providers.vpnProvider.dataUsage { (usage, error) in
            var uploaded = Int64(0)
            var downloaded = Int64(0)
            if error == nil,
                let usage = usage {
                uploaded = Int64(usage.uploaded)
                downloaded = Int64(usage.downloaded)
            }
            self.uploadValue.text = ByteCountFormatter.string(fromByteCount: uploaded,
                                                              countStyle: .file)
            self.downloadValue.text = ByteCountFormatter.string(fromByteCount: downloaded,
                                                                countStyle: .file)
        }
    }
}
