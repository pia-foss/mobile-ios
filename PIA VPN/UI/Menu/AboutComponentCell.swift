//
//  AboutComponentCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
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
import PIADesignSystem
import PIAUIKit

private let log = PIALogger.logger(for: AboutNoticeCell.self)

class AboutNoticeCell: UITableViewCell, Restylable {
    @IBOutlet private weak var buttonName: UIButton!
    
    @IBOutlet private weak var labelCopyright: UILabel!
    
    @IBOutlet private weak var labelNotice: UILabel!
    
    private var component: NoticeComponent?
    
    func fill(withComponent component: NoticeComponent) {
        viewShouldRestyle()
        
        self.component = component
        
        buttonName.setTitle(component.name, for: .normal)
        buttonName.isUserInteractionEnabled = false
        labelCopyright.text = component.copyright
        labelNotice.text = component.notice
        
        buttonName.accessibilityTraits = UIAccessibilityTraits.none
        buttonName.accessibilityLabel = component.name
    }
    
    // MARK: Restylable
    
    func viewShouldRestyle() {
        Theme.current.applySecondaryBackground(self)
        buttonName.style(style: TextStyle.textStyle9)
        Theme.current.applySubtitle(labelCopyright)
        Theme.current.applySubtitle(labelNotice)

    }
}

class AboutLicenseCell: UITableViewCell, Restylable {
    @IBOutlet private weak var buttonName: UIButton!

    @IBOutlet private weak var labelCopyright: UILabel!
    
    @IBOutlet private weak var textLicense: UITextView!
    
    @IBOutlet private weak var activityLicense: UIActivityIndicatorView!
    
    @IBOutlet private weak var buttonMore: UIButton!
    
    @IBOutlet private weak var viewLicenseFooter: UIView!
    
    private weak var gradientLicense: GradientView?
    
    @IBOutlet private weak var constraintMoreTopToLicense: NSLayoutConstraint!  // shrinked

    @IBOutlet private weak var constraintMoreTopToFooter: NSLayoutConstraint!   // expanded
    
    private var component: LicenseComponent?
    
    private var isExpanded = false
    
    private(set) var heightThatFits: CGFloat = 0.0
    
    weak var delegate: AboutLicenseCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    
        textLicense.showsVerticalScrollIndicator = true
        textLicense.scrollsToTop = false
        var textInset = textLicense.textContainerInset
        textInset.bottom = 20.0
        textLicense.textContainerInset = textInset
    }

    func fill(withComponent component: LicenseComponent, license: String?, isExpanded: Bool) {
        viewShouldRestyle()

        self.component = component
        self.isExpanded = isExpanded
        
        let extName = "\(component.name) ⇾"
        buttonName.setTitle(extName, for: .normal)
        labelCopyright.text = component.copyright
        textLicense.text = license
        
        if let _ = license {
            activityLicense.stopAnimating()
            viewLicenseFooter.isHidden = false
            buttonMore.isHidden = false
        } else {
            viewLicenseFooter.isHidden = true
            buttonMore.isHidden = true
            activityLicense.startAnimating()
        }

        var moreImage: UIImage?
        if isExpanded {
            moreImage = Asset.Images.buttonUp.image
            textLicense.isScrollEnabled = true
        } else {
            moreImage = Asset.Images.buttonDown.image
            textLicense.isScrollEnabled = false
        }
        buttonMore.setImage(moreImage, for: .normal)

        buttonName.accessibilityTraits = UIAccessibilityTraits.none
        buttonName.accessibilityLabel = component.name
        buttonName.accessibilityHint = L10n.Localizable.About.Accessibility.Component.expand
    }

    // MARK: Actions
    
    @IBAction private func seeLicense(_ sender: Any?) {
        guard let url = component?.licenseURL else {
            return
        }
        UIApplication.shared.openURL(url)
    }
    
    @IBAction private func toggleLicense(_ sender: Any?) {
        if isExpanded {
            delegate?.aboutCell(self, shouldShrink: textLicense.text)
        } else {
            delegate?.aboutCell(self, shouldExpand: textLicense.text)
        }
        isExpanded = !isExpanded
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        if isExpanded {
            constraintMoreTopToLicense.isActive = false
            constraintMoreTopToFooter.isActive = true
        } else {
            constraintMoreTopToFooter.isActive = false
            constraintMoreTopToLicense.isActive = true
        }
        
        let maxSize = CGSize(width: bounds.size.width, height: .greatestFiniteMagnitude)
        heightThatFits = 120.0 + textLicense.sizeThatFits(maxSize).height
    }

    // MARK: Restylable
    
    func viewShouldRestyle() {
        Theme.current.applySecondaryBackground(self)
        Theme.current.applyPrincipalBackground(textLicense)
        buttonName.style(style: TextStyle.textStyle9)
        Theme.current.applySubtitle(labelCopyright)
        Theme.current.applyLicenseMonospaceFontAndColor(textLicense, appearance: .dark)
        buttonMore.tintColor = textLicense.textColor

        gradientLicense?.removeFromSuperview()
        guard let gradientStartColor = backgroundColor?.withAlphaComponent(0.0) else {
            log.error("Cell has no backgroundColor?")
            return
        }
        guard let gradientEndColor = backgroundColor else {
            log.error("Cell has no backgroundColor?")
            return
        }
        
        let gradientView = GradientView(frame: viewLicenseFooter.bounds)
        let gradient = gradientView.gradientLayer
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewLicenseFooter.addSubview(gradientView)
        gradientLicense = gradientView
    }
}

protocol AboutLicenseCellDelegate: AnyObject {
    func aboutCell(_ cell: AboutLicenseCell, shouldExpand license: String?)

    func aboutCell(_ cell: AboutLicenseCell, shouldShrink license: String?)
}
