//
//  PrivacyFeaturesSettingsViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 21/5/21.
//  Copyright © 2021 Private Internet Access, Inc.
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

import UIKit
import SwiftyBeaver
import PIALibrary
import SafariServices

private let log = SwiftyBeaver.self

class PrivacyFeaturesSettingsViewController: PIABaseSettingsViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private lazy var switchPersistent = UISwitch()
    private lazy var switchContentBlocker = UISwitch()
    private var isContentBlockerEnabled = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
                
        tableView.delegate = self
        tableView.dataSource = self
        
        switchPersistent.addTarget(self, action: #selector(togglePersistentConnection(_:)), for: .valueChanged)
        switchContentBlocker.addTarget(self, action: #selector(showContentBlockerTutorial), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettings), name: .PIASettingsHaveChanged, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshContentBlockerState), name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPersistentConnectionValue),
                                               name: .PIAPersistentConnectionSettingHaveChanged,
                                               object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContentBlockerState()
        styleNavigationBarWithTitle(L10n.Settings.Section.privacyFeatures)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }

    @objc private func reloadSettings() {
        tableView.reloadData()
    }
    
    @objc private func refreshPersistentConnectionValue() {
        pendingPreferences.isPersistentConnection = Client.preferences.isPersistentConnection
        tableView.reloadData()
    }
    
    @objc private func togglePersistentConnection(_ sender: UISwitch) {
        if !sender.isOn,
            Client.preferences.nmtRulesEnabled {
                let alert = Macros.alert(nil, L10n.Settings.Nmt.Killswitch.disabled)
                alert.addCancelAction(L10n.Global.close)
                alert.addActionWithTitle(L10n.Global.enable) { [weak self] in
                    self?.pendingPreferences.isPersistentConnection = true
                    self?.settingsDelegate.refreshSettings()
                    self?.settingsDelegate.reportUpdatedPreferences()
                    self?.reloadSettings()
                }
                present(alert, animated: true, completion: nil)
        }
        
        pendingPreferences.isPersistentConnection = sender.isOn
        self.tableView.reloadData()
        settingsDelegate.reportUpdatedPreferences()

    }
    
    @objc private func refreshContentBlockerState(withHUD: Bool = false) {
        if withHUD {
            self.showLoadingAnimation()
        }
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: AppConstants.Extensions.adBlockerBundleIdentifier) { (state, error) in
            DispatchQueue.main.async {
                self.hideLoadingAnimation()
                self.isContentBlockerEnabled = state?.isEnabled ?? false
                self.tableView.reloadData()
            }
        }
    }

    @objc private func showContentBlockerTutorial() {
        perform(segue: StoryboardSegue.Main.contentBlockerSegueIdentifier)
    }


    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Settings.Section.privacyFeatures)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        tableView.reloadData()
    }

}

extension PrivacyFeaturesSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PrivacyFeaturesSections.all().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section != PrivacyFeaturesSections.refresh.rawValue, let cell = tableView.dequeueReusableCell(withIdentifier: Cells.footer) {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.style(style: TextStyle.textStyle21)
            cell.backgroundColor = .clear
            if section == PrivacyFeaturesSections.killswitch.rawValue {
                cell.textLabel?.text =  L10n.Settings.ApplicationSettings.KillSwitch.footer
            } else {
                cell.textLabel?.text =  L10n.Settings.ContentBlocker.footer
            }
            return cell
        }
        return nil

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default
        cell.detailTextLabel?.text = nil

        let section = PrivacyFeaturesSections.all()[indexPath.section]
        
        switch section {
        case .killswitch:
            cell.textLabel?.text = L10n.Settings.ApplicationSettings.KillSwitch.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchPersistent
            cell.selectionStyle = .none
            switchPersistent.isOn = pendingPreferences.isPersistentConnection

            
        case .safariContentBlocker:
            cell.textLabel?.text = L10n.Settings.ContentBlocker.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchContentBlocker
            cell.selectionStyle = .none
            switchContentBlocker.isOn = isContentBlockerEnabled

        case .refresh:
            cell.textLabel?.text = L10n.Settings.ContentBlocker.Refresh.title
            cell.detailTextLabel?.text = nil

        }

        Theme.current.applySecondaryBackground(cell)
        if let textLabel = cell.textLabel {
            Theme.current.applySettingsCellTitle(textLabel,
                                                 appearance: .dark)
            textLabel.backgroundColor = .clear
        }
        if let detailLabel = cell.detailTextLabel {
            Theme.current.applySubtitle(detailLabel)
            detailLabel.backgroundColor = .clear
        }
        
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = PrivacyFeaturesSections.all()[indexPath.section]

        switch section {
            case .refresh:
                refreshContentBlockerRules()
            default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func edit(_ sender: Any?) {
        self.perform(segue: StoryboardSegue.Main.customDNSSegueIdentifier)
    }

    private func refreshContentBlockerRules() {
        self.showLoadingAnimation()
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: AppConstants.Extensions.adBlockerBundleIdentifier) { (error) in
            if let error = error {
                log.error("Could not reload Safari Content Blocker: \(error)")
            }
            DispatchQueue.main.async {
                self.hideLoadingAnimation()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}
