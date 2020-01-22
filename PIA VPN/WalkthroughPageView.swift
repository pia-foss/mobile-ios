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

class WalkthroughPageView: UIView {
    struct PageData {
        let title: String

        let detail: String

        let image: UIImage?
    }
    
    private let data: PageData

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
        let labelTitle = UILabel()
        let labelDetail = UILabel()
        addSubview(imvImage)
        addSubview(labelTitle)
        addSubview(labelDetail)
        
        translatesAutoresizingMaskIntoConstraints = false
        imvImage.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelDetail.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imvImage.topAnchor.constraint(equalTo: topAnchor),
            imvImage.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.65),
            imvImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelTitle.topAnchor.constraint(equalTo: imvImage.bottomAnchor, constant: 32.5),
            labelTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 40.0),
            labelTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -40.0),
            labelDetail.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 14.0),
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
        
        Theme.current.applySubtitle(labelDetail)
        Theme.current.applyTitle(labelTitle, appearance: .dark)

        labelTitle.textAlignment = .center
        labelDetail.textAlignment = .center

    }
}
