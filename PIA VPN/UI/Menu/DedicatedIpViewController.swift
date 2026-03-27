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
import UIKit
import PIALocalizations

private let log = PIALogger.logger(for: DedicatedIpViewController.self)

final class DedicatedIpViewController: AutolayoutViewController {

    @IBOutlet private weak var tableView: UITableView!
    private var dedicatedIpServer: Server?
    private var timeToRetryDIP: TimeInterval? = nil

    // MARK: Use cases
    private let getDipServer: GetDedicatedIpUseCaseType = DedicatedIPFactory.makeGetDedicatedIpUseCase()
    private let removeDipToken: RemoveDIPUseCaseType = DedicatedIPFactory.makeRemoveDIPUseCase()
    private let activateDipToken: ActivateDIPTokenUseCaseType = DedicatedIPFactory.makeActivateDIPTokenUseCase()

    private enum Section: Int, CaseIterable {
        case header = 0
        case dedicatedIps = 1
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

        title = L10n.Dedicated.Ip.title

        let nc = NotificationCenter.default
        if UserInterface.isIpad {
            nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }

        configureTableView()
        reloadDipServerAndTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Dedicated.Ip.title)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Dedicated.Ip.title)
    }

    @MainActor
    private func reloadDipServerAndTableView() {
        let server: ServerType? = getDipServer()
        guard let server = server as? Optional<Server> else {
            log.error("server should be of type \(Server.self)")
            return
        }
        dedicatedIpServer = server
        tableView.reloadData()
    }
    
    private func configureTableView() {
        tableView.allowsSelection = false
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
    }

    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(L10n.Dedicated.Ip.title)

        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applyPrincipalBackground(tableView)
    }
    
    // MARK: DIP Token handling
    
    private static var invalidTokenLocalisedString: String {
        return L10n.Dedicated.Ip.Message.Invalid.token
    }
    
    private func showInvalidTokenMessage() {
        Macros.displayStickyNote(
            withMessage: Self.invalidTokenLocalisedString,
            andImage: Asset.Images.iconWarning.image,
        )
    }
    
    private func displayErrorMessage(errorMessage: String?, displayDuration: Double? = nil) {
        Macros.displayImageNote(
            withImage: Asset.Images.iconWarning.image,
            message: errorMessage ?? Self.invalidTokenLocalisedString,
            andDuration: displayDuration,
        )
    }

    private func handleDIPActivationError(_ error: Error?) {
        guard let error else {
            showInvalidTokenMessage()
            return
        }

        switch error {
        case ClientError.unauthorized:
            log.error("Activate DIP token failed with unauthorized error. Logging out...")
            Client.providers.accountProvider.logout(nil)
            Macros.postNotification(.PIAUnauthorized)
        case ClientError.throttled(let retryAfter):
            let retryAfterSeconds = Double(retryAfter)
            let localisedThrottlingString = L10n.Dedicated.Ip.Message.Error.retryafter("\(Int(retryAfter))")
            
            displayErrorMessage(errorMessage: NSLocalizedString(localisedThrottlingString, comment: localisedThrottlingString),
                                     displayDuration: retryAfterSeconds)
            timeToRetryDIP = Date().timeIntervalSince1970 + retryAfterSeconds
        default:
            showInvalidTokenMessage()
        }
    }
}

// MARK: Table View

extension DedicatedIpViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dedicatedIpServer == nil ? 1 : Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .header:
            return 0
        case .dedicatedIps:
            return dedicatedIpServer == nil ? 0 : 1
        case .none:
            fatalError("Unknown section number \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.dedicatedIpRow, for: indexPath) as! DedicatedIpRowViewCell
        guard let dedicatedIpServer else {
            log.error("Server expected to exist, was nil")
            return cell
        }
        cell.fill(withServer: dedicatedIpServer)
        Theme.current.applySecondaryBackground(cell)

        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = Macros.alert(nil, L10n.Dedicated.Ip.remove)
            alert.addCancelActionWithTitle(L10n.Global.cancel) { [weak self] in
                guard let self else { return }
                self.reloadDipServerAndTableView()
            }
            
            alert.addActionWithTitle(L10n.Global.ok) { [weak self] in
                guard let self else { return }
                Task {
                    await self.confirmDelete(row: indexPath.row)
                }
            }
            
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    private func confirmDelete(row: Int) async {
        if case let .failure(error) = await removeDipToken() {
            log.error("Error removing DIP token \(error)")
        }
        Macros.postNotification(.PIAThemeDidChange)
        reloadDipServerAndTableView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch (Section(rawValue: section), dedicatedIpServer) {
        case (.header, .none):
            let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.header) as! DedicatedIpEmptyHeaderViewCell
            headerView.setup(withTableView: tableView, delegate: self)
            return headerView

        case (.header, .some):
            let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.activeHeader) as! ActiveDedicatedIpHeaderViewCell
            headerView.setup()
            return headerView

        case (.dedicatedIps, .some):
            let headerView = tableView.dequeueReusableCell(withIdentifier: Cells.titleHeader) as! DedicatedIPTitleHeaderViewCell
            return headerView

        default:
            return nil
        }
    }
}

// MARK: DIP Activation

extension DedicatedIpViewController: DedicatedIpEmptyHeaderViewCellDelegate {
    func handleDIPActivation(with token: String, cell: DedicatedIpEmptyHeaderViewCell) {
        if let timeUntilNextTry = timeToRetryDIP?.timeSinceNow() {
            displayErrorMessage(errorMessage: L10n.Dedicated.Ip.Message.Error.retryafter("\(Int(timeUntilNextTry))"), displayDuration: timeUntilNextTry)
            return
        }
        
        if token.isEmpty {
            Macros.displayStickyNote(withMessage: L10n.Dedicated.Ip.Message.Incorrect.token,
                                     andImage: Asset.Images.iconWarning.image)
            return
        }

        showLoadingAnimation()
        cell.emptyTokenTextField()

        Task { [weak self] in
            guard let self else { return }

            switch await self.activateDipToken(token: token) {
            case .success:
                Macros.displaySuccessImageNote(
                    withImage: Asset.Images.iconWarning.image,
                    message: L10n.Dedicated.Ip.Message.Valid.token,
                )

            case .failure(.expired):
                log.error("Activate DIP token failed with expired token error.")
                Macros.displayStickyNote(
                    withMessage: L10n.Dedicated.Ip.Message.Expired.token,
                    andImage: Asset.Images.iconWarning.image,
                )

            case .failure(.invalid):
                log.error("Activate DIP token failed with invalid token error.")
                Macros.displayStickyNote(
                    withMessage: Self.invalidTokenLocalisedString,
                    andImage: Asset.Images.iconWarning.image,
                )

            case let .failure(.generic(error)):
                self.handleDIPActivationError(error)
            }

            hideLoadingAnimation()
            reloadDipServerAndTableView()

            // Reloads the sever list on the dashboard view controller...
            Macros.postNotification(.PIAThemeDidChange)
        }
    }
}
