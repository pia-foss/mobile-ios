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

import UIKit
import PIALibrary
import DZNEmptyDataSet
import PopupDialog
import GradientProgressBar
import SwiftyBeaver

private let log = SwiftyBeaver.self

class RegionsViewController: AutolayoutViewController {
    private struct Cells {
        static let region = "RegionCell"
    }

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var gradientProgressBar: GradientProgressBar!

    private var servers: [Server] = []
    private var filteredServers = [Server]()
    private var selectedServer: Server!
    private var refreshControl   = UIRefreshControl()

    let searchController = UISearchController(searchResultsController: nil)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = L10n.Menu.Item.region
        var servers = Client.providers.serverProvider.currentServers
        servers.insert(Server.automatic, at: 0)
        
        if Client.configuration.isDevelopment, let customServers = AppConstants.Servers.customServers {
            servers.append(contentsOf: customServers)
        }
        
        let favoriteServers = Client.configuration.currentServerNetwork() == .gen4 ?
            AppPreferences.shared.favoriteServerIdentifiersGen4 :
            AppPreferences.shared.favoriteServerIdentifiers
        
        for server in servers {
            server.isFavorite = favoriteServers.contains(server.identifier)
        }
        
        self.servers = servers
        filterServers()

        selectedServer = Client.preferences.displayedServer

        NotificationCenter.default.addObserver(self, selector: #selector(pingsDidComplete(notification:)), name: .PIADaemonsDidPingServers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)

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
        refreshControl.addTarget(self, action: #selector(refreshLatency), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refreshLatency(_ sender: Any) {

        refreshControl.endRefreshing()

        guard (Client.providers.vpnProvider.vpnStatus == .disconnected) else {
            log.debug("Not pinging servers while on VPN, will try on next update")
            return
        }
        
        gradientProgressBar.setProgress(0.5, animated: true)

        Client.ping(servers: self.servers)
        Macros.dispatch(after: .milliseconds(400)) { [weak self] in
            self?.filterServers()
        }
    }
    

    private func setupRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Piax.Global.iconFilter.image,
            style: .plain,
            target: self,
            action: #selector(showFilter(_:))
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = L10n.Region.Accessibility.filter
    }
    
    override func dismissModal() {

        if searchController.isActive {
            searchController.searchBar.text = ""
            searchController.dismiss(animated: false)
        }

        super.dismissModal()
    }
    
    private func setupSearchBarController() {
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = L10n.Region.Search.placeholder
        self.tableView.tableHeaderView = self.searchController.searchBar
       
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        styleNavigationBarWithTitle(L10n.Menu.Item.region)
        setupRightBarButton()
        
        let selectedRow = servers.index { (server) -> Bool in
            return (server.identifier == selectedServer.identifier)
        }

        tableView.reloadData()
        if let row = selectedRow {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .middle)
        }
    }
    
    // MARK: Actions
    @objc private func showFilter(_ sender: Any?) {
        
        if searchController.isActive {
            searchController.searchBar.text = ""
            searchController.dismiss(animated: false)
        }
        
        let popup = PopupDialog(title: nil,
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
            self.servers = self.servers.sorted(by: { $0.name < $1.name })
        case .latency:
            self.servers = self.servers.sorted(by: { $0.pingTime ?? 0 < $1.pingTime ?? 0 })
        default:
            self.servers = self.servers.sorted(by: { $0.isFavorite && !$1.isFavorite })
        }
        if AppPreferences.shared.showGeoServers == false {
            self.servers = self.servers.filter({ $0.geo == AppPreferences.shared.showGeoServers })
        }
        self.servers.insert(Server.automatic, at: 0)
        
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Menu.Item.region)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segue = StoryboardSegue.Main(rawValue: identifier) else {
            return
        }
        switch segue {
        case .unwindRegionsSegueIdentifier:
            let currentServer = Client.preferences.displayedServer
            guard (selectedServer.identifier != currentServer.identifier) else {
                return
            }
            Client.preferences.displayedServer = selectedServer
            NotificationCenter.default.post(name: .PIAThemeDidChange,
                                            object: self,
                                            userInfo: nil)
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let segue = StoryboardSegue.Main(rawValue: identifier) else {
            return false
        }
        switch segue {
        case .unwindRegionsSegueIdentifier:
            guard let indexPath = tableView.indexPath(for: sender as! UITableViewCell) else {
                fatalError("Segue triggered without an input cell?")
            }
            
            let newSelectedServer: Server
            if isFiltering() {
                newSelectedServer = filteredServers[indexPath.row]
            } else {
                newSelectedServer = servers[indexPath.row]
            }

            selectedServer = newSelectedServer
            tableView.reloadData()
            
            TransientState.shouldDisplayRegionPicker = false

        default:
            break
        }
        return true
    }
    
    // MARK: Notifications
    
    @objc private func pingsDidComplete(notification: Notification) {
        gradientProgressBar.setProgress(100, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConfiguration.Animations.duration, execute: {
            self.gradientProgressBar.setProgress(0, animated: true)
        })
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
        searchController.view.backgroundColor = .clear
        
        Theme.current.applyRegionSolidLightBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        Theme.current.applySearchBarStyle(searchController.searchBar)
        Theme.current.applyRefreshControlStyle(refreshControl)
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        self.tableView.backgroundView = bgView
        
        tableView.reloadData()
    }
}

extension RegionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredServers.count
        }
        
        return servers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.region, for: indexPath) as! RegionCell
        cell.selectionStyle = .none
        cell.separatorInset = .zero
        
        let server: Server
        if isFiltering() {
            server = filteredServers[indexPath.row]
        } else {
            server = servers[indexPath.row]
        }

        let isSelected = (server.identifier == selectedServer.identifier)
        cell.fill(withServer: server, isSelected: isSelected)

        return cell
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
        filteredServers = servers.filter({( server : Server) -> Bool in
            return server.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension RegionsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return Theme.current.noResultsImage()
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        tableView.separatorStyle = .none
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        tableView.separatorStyle = .singleLine
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        searchController.searchBar.resignFirstResponder()
    }
}
