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

public class NavigationLogoView: UIView {
    private let imvLogo: UIImageView
    
    private struct Defaults {
        static let maxWidth: CGFloat = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override init(frame: CGRect) {
        imvLogo = UIImageView(image: Theme.current.palette.logo)
        super.init(frame: .zero)
        
        addSubview(imvLogo)
        
        //        backgroundColor = .orange
        //        imvLogo.backgroundColor = .green
        imvLogo.contentMode = .scaleAspectFit
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //        let navBar = navigationBar()
        let imageLogo = imvLogo.image!
        var imageSize = imageLogo.size
        //        if !Macros.isDevicePad {
        let logoRatio: CGFloat = imageLogo.size.width / imageLogo.size.height
        imageSize.width = min(imageLogo.size.width, Defaults.maxWidth)
        imageSize.height = imageSize.width / logoRatio
        //        }
        
        var logoFrame: CGRect = .zero
        logoFrame.origin.x = -imageSize.width / 2.0
        logoFrame.origin.y = -imageSize.height / 2.0
        logoFrame.size = imageSize
        imvLogo.frame = logoFrame.integral
    }
    
    private func navigationBar() -> UINavigationBar {
        var parent = superview
        while (parent != nil) {
            if let navBar = parent as? UINavigationBar {
                return navBar
            }
            parent = parent?.superview
        }
        fatalError("Not subview of a UINavigationBar")
    }
}
