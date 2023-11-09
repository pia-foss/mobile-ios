//
//  AddCustomNetworksViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 05/08/2020.
//  Copyright © 2020 Private Internet Access, Inc.
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

import UIKit
import PIALibrary

class AddCustomNetworksViewController: AutolayoutViewController {

    private var data = [String]()
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private struct Cells {
        static let network = "CustomNetworkCollectionViewCell"
        static let header = "PIAHeaderCollectionViewCell"
        static let footer = "NetworkFooterCollectionViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popViewController),
                                               name: .TrustedNetworkAdded,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {

        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle("")

        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(collectionView)

        reloadData()

    }
    
    // MARK: Private Methods    
    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: Cells.network,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.network)
        collectionView.register(UINib(nibName: Cells.header, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:Cells.header)
        collectionView.delegate = self
        collectionView.dataSource = self
        reloadData()
    }

    @objc private func reloadData() {
        data = Client.preferences.availableNetworks
        data = data.filter { !Client.preferences.nmtTrustedNetworkRules.keys.contains($0) }

        if let current = PIAHotspotHelper().currentWiFiNetwork(), !data.contains(current) {
            data.append(current)
        }
        self.collectionView.reloadData()
    }
    
    // MARK: Actions
    @objc private func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddCustomNetworksViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.network, for: indexPath) as! CustomNetworkCollectionViewCell
        cell.isSelected = false
        cell.setup(withTitle: data[indexPath.row])
        cell.viewShouldRestyle()
        
        Theme.current.applySecondaryBackground(cell)

        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CustomNetworkCollectionViewCell
        cell.isSelected = true
        cell.showOptions()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cells.header, for: indexPath) as! PIAHeaderCollectionViewCell
        headerView.setup(withTitle: L10n.Network.Management.Tool.Add.rule, andSubtitle: L10n.Network.Management.Tool.Choose.wifi + L10n.Settings.Hotspothelper.Available.help)
        return headerView

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! PIAHeaderCollectionViewCell

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .defaultHigh,
                                                  verticalFittingPriority: .fittingSizeLevel)

    }
    
}
