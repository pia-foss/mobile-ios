//
//  RegionsViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class RegionsViewController: AutolayoutViewController {
    private struct Cells {
        static let region = "RegionCell"
    }

    @IBOutlet private weak var tableView: UITableView!
    
    private var servers: [Server] = []
    private var filteredServers = [Server]()
    private var selectedServer: Server!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = L10n.Menu.Item.region
        var servers = Client.providers.serverProvider.currentServers
        servers.insert(Server.automatic, at: 0)
        self.servers = servers

        selectedServer = Client.preferences.displayedServer

        NotificationCenter.default.addObserver(self, selector: #selector(pingsDidComplete(notification:)), name: .PIADaemonsDidPingServers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewHasRotated), name: .UIDeviceOrientationDidChange, object: nil)

        setupSearchBarController()
    }
    
    private func setupSearchBarController() {
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = L10n.Region.Search.placeholder
        self.tableView.tableHeaderView = self.searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Menu.Item.region)

        let selectedRow = servers.index { (server) -> Bool in
            return (server.identifier == selectedServer.identifier)
        }

        tableView.reloadData()
        if let row = selectedRow {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .middle)
        }
    }
    
    // MARK: Actions
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
        tableView.reloadData()
    }
    
    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        styleNavigationBarWithTitle(L10n.Menu.Item.region)

        if let viewContainer = viewContainer {
            Theme.current.applyLightBackground(view)
            Theme.current.applyLightBackground(viewContainer)
        }
        searchController.view.backgroundColor = .clear
        
        Theme.current.applyLightBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        Theme.current.applySearchBarStyle(searchController.searchBar)
        
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
