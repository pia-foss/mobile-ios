//
//  WalkthroughPageView.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
            labelTitle.topAnchor.constraint(equalTo: imvImage.bottomAnchor, constant: 20.0),
            labelTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 40.0),
            labelTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -40.0),
            labelDetail.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 10.0),
            labelDetail.leftAnchor.constraint(equalTo: labelTitle.leftAnchor),
            labelDetail.rightAnchor.constraint(equalTo: labelTitle.rightAnchor),
            labelDetail.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        imvImage.contentMode = .scaleAspectFit
        imvImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        labelTitle.textAlignment = .center
        labelTitle.numberOfLines = 0
        labelDetail.textAlignment = .center
        labelDetail.numberOfLines = 0
        
        labelTitle.text = data.title
        labelDetail.text = data.detail
        imvImage.image = data.image
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelDetail, appearance: .dark)
    }
}
