//
//  Tileable.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import UIKit

typealias Func = () -> Void

protocol Tileable {
    
    var detailViewAction: Func! {get}
    var view: UIView! {get set}
    var detailSegueIdentifier: String! {get set}
    
    mutating func xibSetup()
    func loadViewFromNib() -> UIView
    
    func isEditable() -> Bool
    func isExpandable() -> Bool
    func hasDetailView() -> Bool
    
}

extension Tileable {

    ///Check if the tile can change the visibility or the order in the list
    /// - Returns: Bool
    func isEditable() -> Bool {
        return false
    }
    
    ///Check if the tile can change the size inside the list
    /// - Returns: Bool
    func isExpandable() -> Bool {
        return false
    }
    
    ///Check if the tile has a detail view controller
    /// - Returns: Bool
    func hasDetailView() -> Bool {
        return false
    }
    
}

extension Tileable where Self: UIView {
    
    /// The initial setup
    mutating func xibSetup() {
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                      UIViewAutoresizing.flexibleHeight]
        addSubview(self.view)
    }
    
    /// The method used to load the xib file
    /// - Returns: The view of the xib file
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PowerTile",
                        bundle: bundle)
        let view = nib.instantiate(withOwner: self,
                                   options: nil)[0] as? UIView
        return view!
    }
    
}
