//
//  RegionListHostingController.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
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

import Combine
import PIAAssetsMobile
import PIALibrary
import PIALocalizations
import PIARegionList
import PIARegionListDomain
import UIKit

/// Hosts `RegionListView` and owns its UIKit navigation bar: search, sort menu and the Mac refresh button.
final class RegionListHostingController: AutolayoutHostingController<RegionListView> {
    private let store: RegionListStore
    private let searchController = UISearchController(searchResultsController: nil)
    private var refreshBarButton: UIBarButtonItem?
    private var cancellables = Set<AnyCancellable>()

    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: Asset.Piax.Global.iconFilter.image, style: .plain, target: nil, action: nil)
        button.accessibilityLabel = L10n.Region.Accessibility.filter
        return button
    }()

    init(store: RegionListStore, onDismiss: @escaping () -> Void) {
        self.store = store
        super.init(rootView: RegionListView(store: store), onDismiss: onDismiss)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var disablesAutomaticKeyboardDismissal: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupBarButtons()

        store.$state
            .map { ($0.content.sort, $0.canRefresh) }
            .removeDuplicates { $0 == $1 }
            .sink { [weak self] sort, canRefresh in
                self?.filterButton.menu = Self.filterMenu(selected: sort) { self?.store.send(.sortSelected($0)) }
                self?.refreshBarButton?.isEnabled = canRefresh
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewShouldRestyle()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.viewShouldRestyle()
        }
    }

    override func dismissModal(completion: (() -> Void)? = nil) {
        if searchController.isActive {
            searchController.searchBar.text = ""
            searchController.dismiss(animated: false)
        }
        super.dismissModal(completion: completion)
    }

    private func setupSearchController() {
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

    private func setupBarButtons() {
        // Mac has no pull-to-refresh, so expose the latency refresh as a navigation bar button.
        if Platform.isRunningOnMac {
            let refreshButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.clockwise"),
                primaryAction: UIAction { [weak self] _ in self?.store.send(.refreshTriggered) }
            )
            refreshBarButton = refreshButton
            navigationItem.rightBarButtonItems = [filterButton, refreshButton]
        } else {
            navigationItem.rightBarButtonItem = filterButton
        }
    }

    private static func filterMenu(selected: RegionFilter, select: @escaping (RegionFilter) -> Void) -> UIMenu {
        let titles: [(RegionFilter, String)] = [
            (.name, L10n.Region.Filter.name),
            (.latency, L10n.Region.Filter.latency),
            (.favorite, L10n.Region.Filter.favorites),
        ]
        return UIMenu(
            title: L10n.Region.Filter.sortby,
            options: [.displayInline, .singleSelection],
            children: titles.map { filter, title in
                UIAction(title: title, state: filter == selected ? .on : .off) { _ in select(filter) }
            }
        )
    }
}

extension RegionListHostingController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.isActive ? (searchController.searchBar.text ?? "") : ""
        store.send(.searchChanged(text))
    }
}
