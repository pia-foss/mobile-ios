//
//  RegionsViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
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

import DZNEmptyDataSet
import GradientProgressBar
import PIAAssetsMobile
import PIALibrary
import PIALocalizations
import PopupDialog
import UIKit

private let log = PIALogger.logger(for: AutolayoutViewController.self)

final class RegionsViewController: AutolayoutViewController {

    private enum Section: Int, CaseIterable {
        case automatic = 0
        case dip
        case regions
    }

    private enum Cells {
        static let region = "RegionCell"
        static let dedicatedRegion = "DedicatedRegionCell"
    }

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var gradientProgressBar: GradientProgressBar!

    weak var serverSelectionDelegate: ServerSelectionDelegate!

    private var servers: [Server] = []
    private var filteredServers = [Server]()
    private var selectedServer: Server!
    private var refreshBarButton: UIBarButtonItem?
    private var refreshControl = UIRefreshControl()

    private let searchController = UISearchController(searchResultsController: nil)

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Menu.Item.region
        let servers = Client.providers.serverProvider.currentServers

        let favoriteServers = AppPreferences.shared.favoriteServerIdentifiersGen4.filterDuplicate { ($0) }

        for server in servers {
            server.isFavorite = favoriteServers.contains(server.identifier + (server.dipToken ?? ""))
        }

        self.servers = servers
        filterServers()

        selectedServer = Client.preferences.displayedServer

        NotificationCenter.default.addObserver(self, selector: #selector(reloadRegions), name: .PIAThemeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pingsDidComplete(notification:)), name: .PIADaemonsDidPingServers, object: nil)
        if UserInterface.isIpad {
            NotificationCenter.default.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }

        setupSearchBarController()
        Macros.stylePopupDialog()

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        setupPullToRefresh()

        gradientProgressBar.backgroundColor = .clear
        gradientProgressBar.progress = 0.0
        gradientProgressBar.gradientColors = [UIColor.piaGreen, UIColor.piaGreenDark20, UIColor.piaGreen]

    }

    private func setupPullToRefresh() {
        #if !targetEnvironment(macCatalyst)
            refreshControl.addTarget(self, action: #selector(refreshLatency), for: .valueChanged)
            tableView.refreshControl = refreshControl
        #endif
    }

    @objc private func refreshLatency(_ sender: Any) {

        refreshControl.endRefreshing()

        guard (Client.providers.vpnProvider.vpnStatus == .disconnected) else {
            Macros.displayImageNote(
                withImage: Asset.iconWarning.image,
                message: L10n.Region.Refresh.Connected.error
            )

            log.debug("Not pinging servers while on VPN, will try on next update")
            return
        }

        refreshBarButton?.isEnabled = false
        gradientProgressBar.setProgress(0.5, animated: true)

        Client.ping(servers: self.servers)
        Macros.dispatch(after: .milliseconds(400)) { [weak self] in
            self?.filterServers()
        }
    }

    private func setupRightBarButton() {
        let filterButton = UIBarButtonItem(
            image: Asset.Piax.Global.iconFilter.image,
            style: .plain,
            target: self,
            action: #selector(showFilter(_:))
        )
        filterButton.accessibilityLabel = L10n.Region.Accessibility.filter

        // Mac has no pull-to-refresh, so expose the latency refresh as a navigation bar button.
        if Platform.isRunningOnMac {
            let refreshButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.clockwise"),
                style: .plain,
                target: self,
                action: #selector(refreshLatency(_:))
            )
            refreshBarButton = refreshButton
            navigationItem.rightBarButtonItems = [filterButton, refreshButton]
        } else {
            navigationItem.rightBarButtonItem = filterButton
        }
    }

    override func dismissModal(completion: (() -> Void)? = nil) {

        if searchController.isActive {
            searchController.searchBar.text = ""
            searchController.dismiss(animated: false)
        }

        super.dismissModal(completion: completion)
    }

    private func setupSearchBarController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.Region.Search.placeholder

        navigationItem.searchController = searchController
        if #available(iOS 26.0, *) {
            navigationItem.preferredSearchBarPlacement = .integratedButton
        }
        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        styleNavigationBarWithTitle(L10n.Menu.Item.region)
        setupRightBarButton()
        tableView.reloadData()

        if selectedServer.isAutomatic {
            tableView.selectRow(at: IndexPath(row: Section.automatic.rawValue, section: Section.automatic.rawValue), animated: false, scrollPosition: UITableView.ScrollPosition.top)
        } else {
            if selectedServer.dipToken == nil {
                let selectedRow = servers.filter({ $0.dipToken == nil }).firstIndex { (server) -> Bool in
                    return (server.identifier == selectedServer.identifier)
                }
                if let row = selectedRow {
                    tableView.selectRow(at: IndexPath(row: row, section: Section.regions.rawValue), animated: false, scrollPosition: UITableView.ScrollPosition.middle)
                }
            } else {
                let dipTokens = Client.providers.serverProvider.dipTokens ?? []
                let selectedRow = servers.filter({ $0.dipToken != nil && dipTokens.contains($0.dipToken!) }).firstIndex { (server) -> Bool in
                    return (server.identifier == selectedServer.identifier)
                }
                if let row = selectedRow {
                    tableView.selectRow(at: IndexPath(row: row, section: Section.dip.rawValue), animated: false, scrollPosition: UITableView.ScrollPosition.top)
                }
            }
        }

    }

    override var disablesAutomaticKeyboardDismissal: Bool { true }

    // MARK: Actions
    @objc private func showFilter(_ sender: Any?) {

        if searchController.isActive {
            searchController.searchBar.text = ""
            searchController.dismiss(animated: false)
        }

        let popup = PopupDialog(
            title: nil,
            message: L10n.Region.Filter.sortby.uppercased())

        let buttonName = DefaultButton(title: L10n.Region.Filter.name.uppercased(), dismissOnTap: true) {
            AppPreferences.shared.regionFilter = .name
            self.filterServers()
        }
        let buttonLatency = DefaultButton(title: L10n.Region.Filter.latency.uppercased(), dismissOnTap: true) {
            AppPreferences.shared.regionFilter = .latency
            self.filterServers()
        }
        let buttonFavorites = DefaultButton(title: L10n.Region.Filter.favorites.uppercased(), dismissOnTap: true) {
            AppPreferences.shared.regionFilter = .favorite
            self.filterServers()
        }

        switch AppPreferences.shared.regionFilter {
        case .name:
            buttonName.titleColor = UIColor.piaGreenDark20
        case .latency:
            buttonLatency.titleColor = UIColor.piaGreenDark20
        default:
            buttonFavorites.titleColor = UIColor.piaGreenDark20
        }

        popup.addButtons([buttonName, buttonLatency, buttonFavorites])
        self.present(popup, animated: true, completion: nil)

    }

    private func filterServers() {
        self.servers = servers.filter({ !$0.isAutomatic })
        switch AppPreferences.shared.regionFilter {
        case .name:
            self.servers = self.servers.sorted(by: {
                return $0.name < $1.name
            })
        case .latency:
            self.servers = self.servers.sorted(by: { $0.pingTime ?? 0 < $1.pingTime ?? 0 })
        default:
            self.servers = self.servers.sorted(by: { $0.isFavorite && !$1.isFavorite })
        }
        if AppPreferences.shared.showGeoServers == false {
            self.servers = self.servers.filter({ $0.geo == AppPreferences.shared.showGeoServers })
        }

        let currentVPNType = Client.providers.vpnProvider.currentVPNType
        self.servers = self.servers.filter { server in
            server.dipToken != nil || server.hasEndpoints(for: currentVPNType)
        }

        tableView.reloadData()
        if tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Menu.Item.region)
    }

    // MARK: Notifications

    @objc private func pingsDidComplete(notification: Notification) {
        refreshBarButton?.isEnabled = true
        gradientProgressBar.setProgress(100, animated: true)
        DispatchQueue.main.asyncAfter(
            deadline: .now() + AppConfiguration.Animations.duration,
            execute: {
                self.gradientProgressBar.setProgress(0, animated: true)
            })
        self.filterServers()
    }

    @objc private func reloadRegions() {
        self.filterServers()
    }

    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        styleNavigationBarWithTitle(L10n.Menu.Item.region)

        if let viewContainer = viewContainer {
            Theme.current.applyRegionSolidLightBackground(view)
            Theme.current.applyRegionSolidLightBackground(viewContainer)
        }

        Theme.current.applyRegionSolidLightBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        Theme.current.applyRefreshControlStyle(refreshControl)

        let bgView = UIView()
        bgView.backgroundColor = .clear
        self.tableView.backgroundView = bgView

        tableView.reloadData()
    }
}

extension RegionsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let count = self.tableView(tableView, numberOfRowsInSection: section)
        guard section < numberOfSections(in: tableView) - 1, count > 0 else { return 0 }
        return 2
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let height = self.tableView(tableView, heightForFooterInSection: section)
        guard height > 0 else { return nil }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: height))
        view.backgroundColor = Theme.current.palette.divider
        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .automatic:
            return isFiltering() ? 0 : 1
        case .dip:
            let dipTokens = Client.providers.serverProvider.dipTokens ?? []
            if isFiltering() {
                return filteredServers.filter({ $0.dipToken != nil && dipTokens.contains($0.dipToken!) }).count
            }
            return servers.filter({ $0.dipToken != nil && dipTokens.contains($0.dipToken!) }).count
        case .regions:
            if isFiltering() {
                return filteredServers.filter({ $0.dipToken == nil }).count
            }
            return servers.filter({ $0.dipToken == nil }).count
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .automatic:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.region, for: indexPath) as! RegionCell
            cell.selectionStyle = .none
            cell.separatorInset = .zero
            let server = Server.automatic
            let isSelected = (server.identifier == selectedServer.identifier)
            cell.fill(withServer: server, isSelected: isSelected)
            return cell

        case .dip:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.dedicatedRegion, for: indexPath) as! DedicatedRegionCell
            cell.selectionStyle = .none
            cell.separatorInset = .zero

            let dipTokens = Client.providers.serverProvider.dipTokens ?? []

            var dipServers = [Server]()
            if isFiltering() {
                dipServers = filteredServers.filter({ $0.dipToken != nil && dipTokens.contains($0.dipToken!) })
            } else {
                dipServers = servers.filter({ $0.dipToken != nil && dipTokens.contains($0.dipToken!) })
            }

            if dipServers.count > 0 {
                let dipServer = dipServers[indexPath.row]
                let isSelected = (dipServer.identifier == selectedServer.identifier && selectedServer.dipToken != nil)
                cell.fill(withServer: dipServer, isSelected: isSelected)
            }
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.region, for: indexPath) as! RegionCell
            cell.selectionStyle = .none
            cell.separatorInset = .zero

            let server: Server
            if isFiltering() {
                server = filteredServers.filter({ $0.dipToken == nil })[indexPath.row]
            } else {
                server = servers.filter({ $0.dipToken == nil })[indexPath.row]
            }

            let isSelected = (server.identifier == selectedServer.identifier && selectedServer.dipToken == nil)
            cell.fill(withServer: server, isSelected: isSelected)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let newSelectedServer: Server

        switch indexPath.section {
        case Section.automatic.rawValue:
            newSelectedServer = Server.automatic
        case Section.dip.rawValue:
            if isFiltering() {
                newSelectedServer = filteredServers.filter({ $0.dipToken != nil })[indexPath.row]
            } else {
                newSelectedServer = servers.filter({ $0.dipToken != nil })[indexPath.row]
            }
        default:
            if isFiltering() {
                newSelectedServer = filteredServers.filter({ $0.dipToken == nil })[indexPath.row]
            } else {
                newSelectedServer = servers.filter({ $0.dipToken == nil })[indexPath.row]
            }
        }

        selectedServer = newSelectedServer

        TransientState.shouldDisplayRegionPicker = false

        let currentServer = Client.preferences.displayedServer
        guard (selectedServer.identifier != currentServer.identifier || selectedServer.dipToken != currentServer.dipToken) else {
            return
        }

        dismissModal {
            self.serverSelectionDelegate.didSelectServer(self.selectedServer)
        }

    }
}

extension RegionsViewController: UISearchResultsUpdating {

    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    // MARK: - Private instance methods

    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredServers = servers.filter({ (server: Server) -> Bool in
            return server.name.lowercased().contains(searchText.lowercased())
        })

        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension RegionsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return Theme.current.noResultsImage()
    }

    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {
        tableView.separatorStyle = .none
    }

    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) {
        tableView.separatorStyle = .singleLine
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {
        searchController.searchBar.resignFirstResponder()
    }
}
