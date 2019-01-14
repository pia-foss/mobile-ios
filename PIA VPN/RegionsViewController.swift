//
//  RegionsViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary
import DZNEmptyDataSet
import PopupDialog

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
        
        let favoriteServers = AppPreferences.shared.favoriteServerIdentifiers
        for server in servers {
            server.isFavorite = favoriteServers.contains(server.identifier)
        }
        
        self.servers = servers
        filterServers()

        selectedServer = Client.preferences.displayedServer

        NotificationCenter.default.addObserver(self, selector: #selector(pingsDidComplete(notification:)), name: .PIADaemonsDidPingServers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewHasRotated), name: .UIDeviceOrientationDidChange, object: nil)

        setupSearchBarController()
        stylePopupDialog()

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
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
    
    private func stylePopupDialog() {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        dialogAppearance.messageFont = TextStyle.textStyle12.font!
        dialogAppearance.messageColor = Theme.current.palette.appearance == .dark ? .white : TextStyle.textStyle12.color
        
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius    = 0
        containerAppearance.shadowEnabled   = false
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color           = .black
        overlayAppearance.blurEnabled     = false
        overlayAppearance.liveBlurEnabled = false
        overlayAppearance.opacity         = 0.5
        
        let buttonAppearance = DefaultButton.appearance()
        buttonAppearance.titleFont      = TextStyle.textStyle21.font!
        buttonAppearance.titleColor     = TextStyle.textStyle21.color
        buttonAppearance.buttonColor    = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        buttonAppearance.separatorColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey10 : UIColor.piaGrey1
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
        tableView.reloadData()
        self.servers.insert(Server.automatic, at: 0)
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
            NotificationCenter.default.post(name: .PIAServerHasBeenUpdated,
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
            Theme.current.applySolidLightBackground(view)
            Theme.current.applySolidLightBackground(viewContainer)
        }
        searchController.view.backgroundColor = .clear
        
        Theme.current.applySolidLightBackground(tableView)
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
