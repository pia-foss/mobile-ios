//
//  ShowConnectionStatsViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 22/3/21.
//  Copyright © 2021 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation
import PIALibrary
import UIKit

private let log = PIALogger.logger(for: ShowConnectionStatsViewController.self)

class ShowConnectionStatsViewController: AutolayoutViewController {

    private var licenseByComponentName: [String: String] = [:]
    
    private var expandedComponentIndex: Int?

    private var expandedComponentHeight: CGFloat = 0.0

    @IBOutlet private weak var textData: UITextView!
    @IBOutlet private weak var textDataContainer: UIView!

    @IBOutlet private weak var viewDataFooter: UIView!
    
    private weak var gradientData: GradientView?
    private(set) var heightThatFits: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        if UserInterface.isIpad {
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        ServiceQualityManager.shared.availableData { data in
            self.textData.text = data.joined(separator: "\n\n")
        }
        
        viewDataFooter.isHidden = false

        textData.isScrollEnabled = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Localizable.Settings.Service.Quality.Show.title)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxSize = CGSize(width: self.view.bounds.size.width, height: .greatestFiniteMagnitude)
        heightThatFits = 120.0 + textData.sizeThatFits(maxSize).height
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Helpers
    
    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Localizable.Settings.Service.Quality.Show.title)
    }
    
    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Localizable.Settings.Service.Quality.Show.title)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }

        Theme.current.applySecondaryBackground(textData)
        Theme.current.applySecondaryBackground(textDataContainer)
        Theme.current.applyLicenseMonospaceFontAndColor(textData, appearance: .dark)

        gradientData?.removeFromSuperview()
        
        guard let gradientStartColor = self.view.backgroundColor?.withAlphaComponent(0.0) else {
            log.error("Cell has no backgroundColor?")
            return
        }
        guard let gradientEndColor = self.view.backgroundColor else {
            log.error("Cell has no backgroundColor?")
            return
        }
        
        let gradientView = GradientView(frame: viewDataFooter.bounds)
        let gradient = gradientView.gradientLayer
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewDataFooter.addSubview(gradientView)
        gradientData = gradientView
    }
}
