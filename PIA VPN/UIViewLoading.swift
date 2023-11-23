//
//  UIViewLoading.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 04/12/2018.
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
import Lottie
import UIKit

extension UIView: AnimatingLoadingDelegate {
    
    private struct LottieRepos {
        static var graphLoad: AnimationView?
    }
    
    var graphLoad: AnimationView? {
        get {
            return objc_getAssociatedObject(self, &LottieRepos.graphLoad) as? AnimationView
        }
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &LottieRepos.graphLoad, unwrappedValue as AnimationView?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public func showLoadingAnimation() {
        if graphLoad == nil {
            graphLoad = AnimationView(name: "pia-spinner")
        }
        addLoadingAnimation()
    }
    
    private func addLoadingAnimation() {
        graphLoad?.loopMode = .loop
        if let graphLoad = graphLoad {
            self.addSubview(graphLoad)
            graphLoad.play()
        }
        setLoadingConstraints()
    }
    
    public func hideLoadingAnimation() {
        graphLoad?.stop()
        graphLoad?.removeFromSuperview()
    }
    
    public func adjustLottieSize() {
        let lottieWidth = self.frame.width/2
        graphLoad?.frame = CGRect(
            x: lottieWidth/2,
            y: (self.frame.height - lottieWidth)/2,
            width: lottieWidth,
            height: lottieWidth
        )
    }
    
    private func setLoadingConstraints() {
        if let graphLoad = graphLoad {
            
            graphLoad.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: graphLoad,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0).isActive = true
            
            NSLayoutConstraint(item: graphLoad,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerY,
                               multiplier: 1.0,
                               constant: 0.0).isActive = true
            
            let lottieWidth = self.frame.width/2

            NSLayoutConstraint(item: graphLoad,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .width,
                               multiplier: 1.0,
                               constant: lottieWidth).isActive = true
            
            NSLayoutConstraint(item: graphLoad,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .height,
                               multiplier: 1.0,
                               constant: lottieWidth).isActive = true
            
        }
    }

}
