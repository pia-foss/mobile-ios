//
//  NavigationLogoView.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 31/10/2018.
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

import Foundation
import UIKit

public final class NavigationLogoView: UIView {
    private let imgLogo: UIImageView = .init()
    
    private struct Defaults {
        static let maxWidth: CGFloat = 100
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    public init(logo: UIImage?) {
        guard let logo else {
            super.init(frame: CGRect(origin: .zero, size: .zero))
            return
        }
        
        imgLogo.image = logo

        // Calculate the frame based on the logo image
        let logoRatio = logo.size.width / logo.size.height
        let width = min(logo.size.width, Defaults.maxWidth)
        let height = width / logoRatio
        let imageSize = CGSize(width: width, height: height)

        super.init(frame: CGRect(origin: .zero, size: imageSize))

        addSubview(imgLogo)
        imgLogo.contentMode = .scaleAspectFit
        imgLogo.frame = bounds
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        imgLogo.frame = bounds
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let image = imgLogo.image else {
            return .zero
        }

        let logoRatio = image.size.width / image.size.height
        let width = min(image.size.width, Defaults.maxWidth)
        let height = width / logoRatio
        return CGSize(width: width, height: height)
    }
}
