//
//  OptionsViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

/// Displays an `UITableView` with a list of dynamically rendered options.
public class OptionsViewController: AutolayoutViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView!

    /// The list of options.
    public var options: [AnyHashable] = []

    /// The initially selected option (optional).
    public var selectedOption: AnyHashable?

    /// The tag of this controller for future reference.
    public var tag = 0

    /// The `OptionsViewControllerDelegate` for rendering and events.
    public weak var delegate: OptionsViewControllerDelegate?
    
    // FIXME: table view "expands" on appearance
    
    /// :nodoc:
    public override func viewDidLoad() {
        let viewContainer = UIView(frame: view.bounds)
        viewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewContainer.backgroundColor = .clear
        view.addSubview(viewContainer)
        self.viewContainer = viewContainer
        
        if #available(iOS 11.0, *) {
            viewContainer.insetsLayoutMarginsFromSafeArea = false
        }

        super.viewDidLoad()
        
        guard let bgColor = delegate?.backgroundColorForOptionsController(self) else {
            return
        }
        viewContainer.backgroundColor = bgColor
        guard let style = delegate?.tableStyleForOptionsController(self) else {
            return
        }
        tableView = UITableView(frame: viewContainer.bounds, style: style)
        tableView.backgroundColor = bgColor
        tableView.dataSource = self
        tableView.delegate = self
        viewContainer.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: viewContainer.layoutMarginsGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: viewContainer.layoutMarginsGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: viewContainer.layoutMarginsGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: viewContainer.layoutMarginsGuide.rightAnchor)
        ])

        delegate?.optionsController(self, didLoad: tableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewHasRotated), name: .UIDeviceOrientationDidChange, object: nil)
        
        viewShouldRestyle()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(self.navigationController?.title ?? "")
    }
    
    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(self.navigationController?.title ?? "")
    }

    // MARK: Restylable
    
    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(self.navigationController?.title ?? "")
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyLightBackground(view)
            Theme.current.applyLightBackground(viewContainer)
        }
        if tableView != nil {
            Theme.current.applyLightBackground(tableView)
            Theme.current.applyDividerToSeparator(tableView)
            tableView.reloadData()
        }
        
    }

    // MARK: UITableViewDataSource
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = delegate?.optionsController(self, tableView: tableView, reusableCellAt: indexPath) else {
            fatalError("Implement optionsController:tableView:reusableCellAt: in delegate")
        }

        let option = options[indexPath.row]
        var isSelected = false
        if let selectedOption = selectedOption {
            isSelected = (option == selectedOption)
        }
        delegate?.optionsController(self, renderOption: option, in: cell, at: indexPath.row, isSelected: isSelected)

        Theme.current.applySolidLightBackground(cell)
        if let textLabel = cell.textLabel {
            Theme.current.applySettingsCellTitle(textLabel,
                                                 appearance: .dark)
        }
        if let detailLabel = cell.detailTextLabel {
            Theme.current.applySubtitle(detailLabel)
        }

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
    
        delegate?.optionsController(self, didSelectOption: option, at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/// Handles rendering and receives events of an `OptionsViewController`.
public protocol OptionsViewControllerDelegate: class {

    /**
     Sets the background color of the view controller.
     */
    func backgroundColorForOptionsController(_ controller: OptionsViewController) -> UIColor

    /**
     Sets the `UITableViewStyle` for the table view.
     */
    func tableStyleForOptionsController(_ controller: OptionsViewController) -> UITableViewStyle

    /**
     Called after loading the embedded `UITableView`.

     - Parameter tableView: The loaded `UITableView`.
     */
    func optionsController(_ controller: OptionsViewController, didLoad tableView: UITableView)

    /**
     Returns a reusable `UITableViewCell` for displaying the options.

     - Parameter tableView: The parent `UITableView`.
     - Parameter indexPath: The `IndexPath` for caching purposes.
     */
    func optionsController(_ controller: OptionsViewController, tableView: UITableView, reusableCellAt indexPath: IndexPath) -> UITableViewCell

    /**
     Renders an option in a reusable `UITableViewCell` as returned by `optionsController(_:tableView:reusableCellAt:)`.

     - Parameter option: The generic option to render.
     - Parameter cell: The `UITableViewCell` in which to render the option.
     - Parameter row: The row the option is in.
     - Parameter isSelected: If `true`, the option is to be rendered selected.
     */
    func optionsController(_ controller: OptionsViewController, renderOption option: AnyHashable, in cell: UITableViewCell, at row: Int, isSelected: Bool)

    /**
     Called when an option is selected.

     - Parameter option: The selected option.
     - Parameter row: The row the option is in.
     */
    func optionsController(_ controller: OptionsViewController, didSelectOption option: AnyHashable, at row: Int)
}
