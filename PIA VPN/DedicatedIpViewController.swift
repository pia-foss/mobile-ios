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
import UIKit

private let log = SwiftyBeaver.self

class DedicatedIpViewController: AutolayoutViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private var data = [Server]()
    private var timeToRetryDIP: TimeInterval? = nil
    
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
        static let activeHeader = "ActiveDedicatedIpHeaderViewCell"
        static let titleHeader = "DedicatedIPTitleHeaderViewCell"
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Localizable.Dedicated.Ip.title

        let nc = NotificationCenter.default
        if UserInterface.isIpad {
            nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        nc.addObserver(self, selector: #selector(reloadTableView), name: .DedicatedIpReload, object: nil)
        nc.addObserver(self, selector: #selector(showLoadingAnimation), name: .DedicatedIpShowAnimation, object: nil)
        nc.addObserver(self, selector: #selector(hideLoadingAnimation), name: .DedicatedIpHideAnimation, object: nil)

        configureTableView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Localizable.Dedicated.Ip.title)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Localizable.Dedicated.Ip.title)
    }
    
    @objc private func reloadTableView() {
        let dipTokens = Client.providers.serverProvider.dipTokens ?? []
        data = Client.providers.serverProvider.currentServers.filter({ $0.dipToken != nil && dipTokens.contains($0.dipToken!) })
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
        tableView.register(UINib(nibName: Cells.activeHeader, bundle: nil),
                           forCellReuseIdentifier:Cells.activeHeader)
        tableView.register(UINib(nibName: Cells.titleHeader, bundle: nil),
                           forCellReuseIdentifier:Cells.titleHeader)
        tableView.delegate = self
        tableView.dataSource = self
        
        reloadTableView()
    }

    
    // MARK: Restylable
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(L10n.Localizable.Dedicated.Ip.title)

        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applyPrincipalBackground(tableView)
        self.tableView.reloadData()

    }
    
    // MARK: DIP Token handling
    
    private var invalidTokenLocalisedString: String {
        get {
            return L10n.Localizable.Dedicated.Ip.Message.Invalid.token
        }
    }
    
    private func showInvalidTokenMessage() {
        Macros.displayStickyNote(withMessage: invalidTokenLocalisedString, andImage: Asset.Images.iconWarning.image)
    }
    
    private func displayErrorMessage(errorMessage: String?, displayDuration: Double? = nil) {
        Macros.displayImageNote(withImage: Asset.Images.iconWarning.image, message: errorMessage ?? invalidTokenLocalisedString, andDuration: displayDuration)
    }
    
    private func handleDIPActivationError(_ error: ClientError) {
        switch error {
        case .unauthorized:
            Client.providers.accountProvider.logout(nil)
            Macros.postNotification(.PIAUnauthorized)
        case .throttled(let retryAfter):
            let retryAfterSeconds = Double(retryAfter)
            let localisedThrottlingString = L10n.Localizable.Dedicated.Ip.Message.Error.retryafter("\(Int(retryAfter))")
            
            displayErrorMessage(errorMessage: NSLocalizedString(localisedThrottlingString, comment: localisedThrottlingString),
                                     displayDuration: retryAfterSeconds)
            timeToRetryDIP = Date().timeIntervalSince1970 + retryAfterSeconds
        default:
            showInvalidTokenMessage()
        }
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
            let alert = Macros.alert(nil, L10n.Localizable.Dedicated.Ip.remove)
            alert.addCancelActionWithTitle(L10n.Localizable.Global.cancel, handler: {
                self.reloadTableView()
            })
            
            alert.addActionWithTitle(L10n.Localizable.Global.ok) {
                self.confirmDelete(row: indexPath.row)
            }
            
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    private func confirmDelete(row: Int) {
        let dipRegion = data[row]
        if let token = dipRegion.dipToken {
            dipRegion.unfavorite()
            Client.providers.serverProvider.removeDIPToken(token)
            NotificationCenter.default.post(name: .PIAThemeDidChange,
                                            object: self,
                                            userInfo: nil)
        }
        reloadTableView()
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
            if !data.isEmpty && AppPreferences.shared.disablesMultiDipTokens{
                let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.activeHeader) as! ActiveDedicatedIpHeaderViewCell
                headerView.setup()
                return headerView
            } else {
                let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.header) as! DedicatedIpEmptyHeaderViewCell
                headerView.setup(withTableView: tableView, delegate: self)
                return headerView
            }
        } else {
            let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.titleHeader) as! DedicatedIPTitleHeaderViewCell
            return headerView
        }
    }
    
}

extension DedicatedIpViewController: DedicatedIpEmptyHeaderViewCellDelegate {
    func handleDIPActivation(with token: String, cell: DedicatedIpEmptyHeaderViewCell) {
        if let timeUntilNextTry = timeToRetryDIP?.timeSinceNow() {
            displayErrorMessage(errorMessage: L10n.Localizable.Dedicated.Ip.Message.Error.retryafter("\(Int(timeUntilNextTry))"), displayDuration: timeUntilNextTry)
            return
        }
        
        if token.isEmpty {
            Macros.displayStickyNote(withMessage: L10n.Localizable.Dedicated.Ip.Message.Incorrect.token,
                                     andImage: Asset.Images.iconWarning.image)
            return
        }
        
        NotificationCenter.default.post(name: .DedicatedIpShowAnimation, object: nil)
        Client.providers.serverProvider.activateDIPToken(token) { [weak self] (server, error) in
            NotificationCenter.default.post(name: .DedicatedIpHideAnimation, object: nil)
            cell.emptyTokenTextField()
            guard let dipServer = server else {
                
                guard let error = error as? ClientError else {
                    self?.showInvalidTokenMessage()
                    return
                }
                
                self?.handleDIPActivationError(error)
                return
            }
            switch dipServer?.dipStatus {
            case .active:
                Macros.displaySuccessImageNote(withImage: Asset.Images.iconWarning.image, message: L10n.Localizable.Dedicated.Ip.Message.Valid.token)
            case .expired:
                print(L10n.Localizable.Dedicated.Ip.Message.Expired.token) // we dont show the message to the user
            default:
                Macros.displayStickyNote(withMessage: self?.invalidTokenLocalisedString ?? "", andImage: Asset.Images.iconWarning.image)
            }
            NotificationCenter.default.post(name: .DedicatedIpReload, object: nil)
            NotificationCenter.default.post(name: .PIAThemeDidChange, object: nil)
        }
    }
}
