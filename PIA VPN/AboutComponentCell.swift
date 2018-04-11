//
//  AboutComponentCell.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

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
        
        buttonName.accessibilityTraits = UIAccessibilityTraitNone
        buttonName.accessibilityLabel = component.name
    }
    
    // MARK: Restylable
    
    func viewShouldRestyle() {
        Theme.current.applySolidLightBackground(self)
        Theme.current.applyTextButton(buttonName)
        Theme.current.applySmallInfo(labelCopyright, appearance: .dark)
        Theme.current.applySmallInfo(labelNotice, appearance: .dark)
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
            moreImage = Asset.buttonUp.image
            textLicense.isScrollEnabled = true
        } else {
            moreImage = Asset.buttonDown.image
            textLicense.isScrollEnabled = false
        }
        buttonMore.setImage(moreImage, for: .normal)

        buttonName.accessibilityTraits = UIAccessibilityTraitNone
        buttonName.accessibilityLabel = component.name
        buttonName.accessibilityHint = L10n.About.Accessibility.Component.expand
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
        Theme.current.applySolidLightBackground(self)
        Theme.current.applyLightBackground(textLicense)
        Theme.current.applyTextButton(buttonName)
        Theme.current.applySmallInfo(labelCopyright, appearance: .dark)
        Theme.current.applyBody1Monospace(textLicense, appearance: .dark)
        buttonMore.tintColor = textLicense.textColor

        gradientLicense?.removeFromSuperview()
        guard let gradientStartColor = backgroundColor?.withAlphaComponent(0.0) else {
            fatalError("Cell has no backgroundColor?")
        }
        guard let gradientEndColor = backgroundColor else {
            fatalError("Cell has no backgroundColor?")
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

protocol AboutLicenseCellDelegate: class {
    func aboutCell(_ cell: AboutLicenseCell, shouldExpand license: String?)

    func aboutCell(_ cell: AboutLicenseCell, shouldShrink license: String?)
}
