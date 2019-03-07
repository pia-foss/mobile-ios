//
//  UIViewLoading.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 04/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import Lottie

extension UIView: AnimatingLoadingDelegate {
    
    private struct LottieRepos {
        static var graphLoad: LOTAnimationView?
    }
    
    var graphLoad: LOTAnimationView? {
        get {
            return objc_getAssociatedObject(self, &LottieRepos.graphLoad) as? LOTAnimationView
        }
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &LottieRepos.graphLoad, unwrappedValue as LOTAnimationView?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public func showLoadingAnimation() {
        if graphLoad == nil {
            graphLoad = LOTAnimationView(name: "pia-spinner")
        }
        addLoadingAnimation()
    }
    
    private func addLoadingAnimation() {
        graphLoad?.loopAnimation = true
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
