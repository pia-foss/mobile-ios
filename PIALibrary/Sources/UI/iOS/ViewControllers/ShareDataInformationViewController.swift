//
//  ShareDataInformationViewController.swift
//  PIALibrary
//
//  Created by Miguel Berrocal on 17/6/21.
//


import Foundation
class ShareDataInformationViewController: AutolayoutViewController {

    @IBOutlet private weak var labelInformation: UILabel!

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelInformation.text = L10n.Signup.Share.Data.ReadMore.Text.description
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        Theme.current.applyPrincipalBackground(contentView)
        Theme.current.applySubtitle(labelInformation)
    }
    
    @IBAction private func close() {
        dismissModal()
    }
    
}
