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

    private var selectedServer: Server!
    
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
            let newSelectedServer = servers[indexPath.row]
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
        Theme.current.applyLightBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        tableView.reloadData()
    }
}

extension RegionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.region, for: indexPath) as! RegionCell
    
        let server = servers[indexPath.row]
        let isSelected = (server.identifier == selectedServer.identifier)
        cell.fill(withServer: server, isSelected: isSelected)
        
        return cell
    }
}
