//
//  PIACard.swift
//  PIA VPN
//
//  Created by Jose Blaya on 10/07/2020.
//  Copyright © 2020 Private Internet Access Inc. All rights reserved.
//

import UIKit
import PIALibrary
import PIADesignSystem

class PIACard: UIView {

    var cardBackgroundImage: ImageAsset!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cardBgImageView: UIImageView!
    @IBOutlet weak var cardParallaxImageView: UIImageView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardDescription: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cardCTAButton: PIAButton!
    @IBOutlet weak var cardSecondaryCTAButton: UIButton!

    public func setupView() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        
        viewShouldRestyle()
        addParallaxToView(vw: cardParallaxImageView)
    }

    @objc private func viewShouldRestyle() {
        
        self.closeButton.tintColor = Theme.current.palette.appearance == .dark ? .white : Macros.color(hex: "111621", alpha: 1)
        self.cardBgImageView.image = UIImage(asset: cardBackgroundImage)
        self.cardTitle.style(style: Theme.current.palette.appearance == .dark ? TextStyle.textStyleCardTitleDark : TextStyle.textStyleCardTitleLight)
        self.cardDescription.style(style: Theme.current.palette.appearance == .dark ? TextStyle.textStyle6 : TextStyle.textStyle7)
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = Theme.current.palette.appearance == .dark ? Macros.color(hex: "111621", alpha: 1) : .white
        self.contentView.layer.borderColor = Theme.current.palette.appearance == .dark ? UIColor.white.withAlphaComponent(0.5).cgColor : Macros.color(hex: "111621", alpha: 1).withAlphaComponent(0.5).cgColor
        self.contentView.layer.borderWidth = 0.5
        self.cardCTAButton.layer.cornerRadius = 6.0
        self.cardSecondaryCTAButton.style(style: TextStyle.Buttons.piaPlainTextButton)
        Theme.current.applyButtonLabelMediumStyle(cardSecondaryCTAButton)

    }

    func addParallaxToView(vw: UIView) {
        let amount = 20

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
}
