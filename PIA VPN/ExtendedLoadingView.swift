//
//  ShowExtendedLoadingView.swift
//  PIA VPN
//
//  Created by Angel Landoni on 14/8/24.
//  Copyright © 2024 Private Internet Access, Inc.
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
import DeviceCheck

final class ExtendedLoadingView: UIView {
    struct PageData {
        let title: String
        let detail: String
        let image: UIImage?
    }
    
    private let data: PageData
    
    private(set) var labelTitle = UILabel()
    private(set) var labelDetail = UILabel()
    private let loadingSpinner = UIActivityIndicatorView(style: .whiteLarge)

    required init?(coder aDecoder: NSCoder) {
        data = PageData(title: "", detail: "", image: nil)
        super.init(coder: aDecoder)
    }
    
    init(data: PageData) {
        self.data = data
        super.init(frame: .zero)

        configure()
        applyStyles()
    }
    
    private func configure() {
        Theme.current.applyPrincipalBackground(self)
        
        Theme.current.applyActivityIndicator(loadingSpinner)
        
        let imvImage = UIImageView()
        
        var imageMultiplier: CGFloat = 0.55

        switch UIDevice().type {
            case .iPhoneSE, .iPhone5, .iPhone5S:
                imageMultiplier = 0.40
            default: break
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        imvImage.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelDetail.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [
            imvImage,
            labelTitle,
            labelDetail,
            loadingSpinner
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imvImage.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: imageMultiplier),
            heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height),
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 70),
            loadingSpinner.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        imvImage.contentMode = .scaleAspectFit
        imvImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        labelTitle.numberOfLines = 0
        labelTitle.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        labelDetail.numberOfLines = 0
        labelDetail.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        if #available(iOS 13.0, *) {
            loadingSpinner.style = .large
        }
        loadingSpinner.startAnimating()

        labelTitle.text = data.title
        labelDetail.text = data.detail
        imvImage.image = data.image
        
        labelTitle.textAlignment = .center
        labelDetail.textAlignment = .center
    }
    
    func applyStyles() {
        Theme.current.applySubtitle(labelDetail)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyActivityIndicator(loadingSpinner)
    }
}

