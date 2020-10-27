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
    
    @IBOutlet private weak var tableView: UITableView!
    private var data = [Server]()

    private struct Sections {
        static let header = 0
        static let dedicatedIps = 1
        
        static func numberOfSections() -> Int {
            return 2
        }
        
    }
    
    private struct Cells {
        static let dedicatedIpRow = "DedicatedIpRowViewCell"
        static let header = "DedicatedIpEmptyHeaderViewCell"
        static let titleHeader = "DedicatedIPTitleHeaderViewCell"
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Dedicated IP"

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        nc.addObserver(self, selector: #selector(reloadTableView), name: .DedicatedIpReload, object: nil)
        nc.addObserver(self, selector: #selector(showLoadingAnimation), name: .DedicatedIpShowAnimation, object: nil)
        nc.addObserver(self, selector: #selector(hideLoadingAnimation), name: .DedicatedIpHideAnimation, object: nil)

        configureTableView()

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
    
    @objc private func reloadTableView() {
        data = Client.providers.serverProvider.currentServers.filter({ $0.dipToken != nil })
        tableView.reloadData()
    }
    
    private func configureTableView() {
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
        tableView.estimatedSectionHeaderHeight = 1.0
        tableView.register(UINib(nibName: Cells.dedicatedIpRow,
                                      bundle: nil),
                           forCellReuseIdentifier: Cells.dedicatedIpRow)
        tableView.register(UINib(nibName: Cells.header, bundle: nil),
                           forCellReuseIdentifier:Cells.header)
        tableView.register(UINib(nibName: Cells.titleHeader, bundle: nil),
                           forCellReuseIdentifier:Cells.titleHeader)
        tableView.delegate = self
        tableView.dataSource = self
        
        reloadTableView()
    }

    
    // MARK: Restylable
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle("Dedicated IP")

        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applyPrincipalBackground(tableView)
        self.tableView.reloadData()

    }

}

extension DedicatedIpViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.isEmpty ? 1 : Sections.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.header == section ? 0 : data.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.dedicatedIpRow, for: indexPath) as! DedicatedIpRowViewCell
        let server = data[indexPath.row]
        cell.fill(withServer: server)
        Theme.current.applySecondaryBackground(cell)

        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dipRegion = data[indexPath.row]
            if let token = dipRegion.dipToken {
                Client.providers.serverProvider.removeDIPToken(token)
                NotificationCenter.default.post(name: .PIAThemeDidChange,
                                                object: self,
                                                userInfo: nil)
            }
            reloadTableView()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if Sections.header == section {
            let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.header) as! DedicatedIpEmptyHeaderViewCell
            headerView.setup(withTableView: tableView)
            return headerView
        } else {
            let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.titleHeader) as! DedicatedIPTitleHeaderViewCell
            return headerView
        }
    }
    
}