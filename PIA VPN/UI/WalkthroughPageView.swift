//
//  WalkthroughPageView.swift
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
import DeviceCheck

class WalkthroughPageView: UIView {
    struct PageData {
        let title: String

        let detail: String

        let image: UIImage?
    }
    
    private let data: PageData
    
    private(set) var labelTitle = UILabel()
    private(set) var labelDetail = UILabel()

    required init?(coder aDecoder: NSCoder) {
        data = PageData(title: "", detail: "", image: nil)
        super.init(coder: aDecoder)
    }
    
    init(data: PageData) {
        self.data = data
        super.init(frame: .zero)

        configure()
    }
    
    private func configure() {
        let imvImage = UIImageView()

        addSubview(imvImage)
        addSubview(labelTitle)
        addSubview(labelDetail)
        
        translatesAutoresizingMaskIntoConstraints = false
        imvImage.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelDetail.translatesAutoresizingMaskIntoConstraints = false
        
        var imageMultiplier: CGFloat = 0.55
        var labelSpaceMargin: CGFloat = 5.0
        var textTopMargin: CGFloat = 19.0

        switch UIDevice().type {
            case .iPhoneSE, .iPhone5, .iPhone5S:
                imageMultiplier = 0.40
                labelSpaceMargin = 2.0
                textTopMargin = 5.0
            default: break
        }

        NSLayoutConstraint.activate([
            imvImage.topAnchor.constraint(equalTo: topAnchor),
            imvImage.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: imageMultiplier),
            imvImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelTitle.topAnchor.constraint(equalTo: imvImage.bottomAnchor, constant: textTopMargin),
            labelTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 40.0),
            labelTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -40.0),
            labelDetail.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: labelSpaceMargin),
            labelDetail.leftAnchor.constraint(equalTo: labelTitle.leftAnchor),
            labelDetail.rightAnchor.constraint(equalTo: labelTitle.rightAnchor),
            labelDetail.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        imvImage.contentMode = .scaleAspectFit
        imvImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        labelTitle.numberOfLines = 0
        labelDetail.numberOfLines = 0
        
        labelTitle.text = data.title
        labelDetail.text = data.detail
        imvImage.image = data.image
        
        labelTitle.textAlignment = .center
        labelDetail.textAlignment = .center

    }
    
    func applyStyles() {
        Theme.current.applySubtitle(labelDetail)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
    }
    
}
