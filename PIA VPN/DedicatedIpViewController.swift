//
//  DedicatedIpViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 13/10/2020.
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

import Foundation
import PIALibrary
import SwiftyBeaver

private let log = SwiftyBeaver.self

class DedicatedIpViewController: AutolayoutViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var data = [String]()

    private struct Sections {
        static let header = 0
        static let dedicatedIps = 1
        
        static func numberOfSections() -> Int {
            return 2
        }
        
    }
    
    private struct Cells {
        static let dedicatedIpRow = "DedicatedIpRowCollectionViewCell"
        static let header = "DedicatedIpEmptyHeaderCollectionViewCell"
        static let titleHeader = "DedicatedIPTitleHeaderCollectionViewCell"
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Dedicated IP"

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        nc.addObserver(self, selector: #selector(reloadCollectionView), name: .DedicatedIpReload, object: nil)

        configureCollectionView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle("Dedicated IP")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle("Dedicated IP")
    }
    
    @objc private func reloadCollectionView() {
        data.append("a")
        collectionView.reloadData()
    }
    
    private func configureCollectionView() {

        let layout = collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(
                width: collectionView.widestCellWidth,
                height: 100
            )
        }

        collectionView.collectionViewLayout = AutoInvalidatingLayout()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: Cells.dedicatedIpRow,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.dedicatedIpRow)
        collectionView.register(UINib(nibName: Cells.header, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:Cells.header)
        collectionView.register(UINib(nibName: Cells.titleHeader, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:Cells.titleHeader)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    
    // MARK: Restylable
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(L10n.Menu.Item.account)

        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applyPrincipalBackground(collectionView)
        self.collectionView.reloadData()

    }

}

extension DedicatedIpViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.isEmpty ? 1 : Sections.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Sections.header == section ? 0 : data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.dedicatedIpRow, for: indexPath) as! DedicatedIpRowCollectionViewCell
        cell.fill(withServer: Server.automatic)
        Theme.current.applySecondaryBackground(cell)

        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {

        case UICollectionView.elementKindSectionHeader:
            if Sections.header == indexPath.section {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cells.header, for: indexPath) as! DedicatedIpEmptyHeaderCollectionViewCell
                headerView.setup()
                return headerView
            } else {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cells.titleHeader, for: indexPath) as! DedicatedIPTitleHeaderCollectionViewCell
                return headerView
            }

        default:
            return UICollectionReusableView()

        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        
        if Sections.header == indexPath.section {
            let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! DedicatedIpEmptyHeaderCollectionViewCell
            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                      withHorizontalFittingPriority: .defaultHigh,
                                                      verticalFittingPriority: .fittingSizeLevel)
        } else {
            let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! DedicatedIPTitleHeaderCollectionViewCell
            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                      withHorizontalFittingPriority: .defaultHigh,
                                                      verticalFittingPriority: .fittingSizeLevel)
        }


    }
    
}
