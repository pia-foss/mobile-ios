//
//  SettingPopoverSelectionView.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 19/5/21.
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
import PIALibrary
import Popover
import TunnelKit

class SettingPopoverSelectionView: UIView {

    weak var currentPopover: Popover!
    weak var pendingPreferences: Client.Preferences.Editable!
    weak var settingsDelegate: SettingsDelegate!
    
    let cellReuseIdentifier = "cell"

    let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let cellTextStyle = {
        Theme.current.palette.appearance == .dark ? TextStyle.textStyle6 : TextStyle.textStyle7
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true

        Theme.current.applyPrincipalBackground(self)
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class ProtocolPopoverSelectionView: SettingPopoverSelectionView {

    var protocols: [String]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ProtocolPopoverSelectionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return protocols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else {
            fatalError("no protocol available")
        }
        cell.textLabel?.style(style: cellTextStyle)

        cell.textLabel?.text = protocols[indexPath.row].vpnProtocol
        cell.textLabel?.accessibilityLabel = protocols[indexPath.row].vpnProtocol
                
        Theme.current.applySecondaryBackground(cell)
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vpnType = protocols[indexPath.row]
        pendingPreferences.vpnType = vpnType
        settingsDelegate.updateSetting(ProtocolsSections.protocolSelection, withValue: nil)
        
        Macros.postNotification(.PIASettingsHaveChanged)
        Macros.postNotification(.RefreshSettings)

        currentPopover.dismiss()
    }

}

class TransportPopoverSelectionView: SettingPopoverSelectionView {

    var options: [String]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TransportPopoverSelectionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else {
            fatalError("no transport available")
        }
        cell.textLabel?.style(style: cellTextStyle)

        if options[indexPath.row] == ProtocolSettingsViewController.AUTOMATIC_SOCKET {
            cell.textLabel?.text = L10n.Global.automatic
        } else {
            cell.textLabel?.text = options[indexPath.row]
        }
        cell.textLabel?.accessibilityLabel = options[indexPath.row]
                
        Theme.current.applySecondaryBackground(cell)
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let socketType = options[indexPath.row]
        
        let type = SocketType(rawValue: socketType)
        settingsDelegate.updateSocketType(socketType: type)
        Macros.postNotification(.PIASettingsHaveChanged)
        
        currentPopover.dismiss()
    }

}

class PortPopoverSelectionView: SettingPopoverSelectionView {

    var options: [UInt16]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PortPopoverSelectionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else {
            fatalError("no transport available")
        }
        cell.textLabel?.style(style: cellTextStyle)

        if options[indexPath.row] == ProtocolSettingsViewController.AUTOMATIC_PORT {
            cell.textLabel?.text = L10n.Global.automatic
        } else {
            cell.textLabel?.text = options[indexPath.row].description
        }
        cell.textLabel?.accessibilityLabel = options[indexPath.row].description
                
        Theme.current.applySecondaryBackground(cell)
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let port = options[indexPath.row]
        
        settingsDelegate.updateRemotePort(port: port)
        Macros.postNotification(.PIASettingsHaveChanged)
        
        currentPopover.dismiss()
    }

}

class DataEncryptionPopoverSelectionView: SettingPopoverSelectionView {

    var options: [String]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension DataEncryptionPopoverSelectionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else {
            fatalError("no transport available")
        }
        cell.textLabel?.style(style: cellTextStyle)

        cell.textLabel?.text = options[indexPath.row].description
        cell.textLabel?.accessibilityLabel = options[indexPath.row].description
                
        Theme.current.applySecondaryBackground(cell)
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let value = options[indexPath.row]
        
        settingsDelegate.updateDataEncryption(encryption: value)
        Macros.postNotification(.PIASettingsHaveChanged)
        
        currentPopover.dismiss()
    }

}

class HandshakePopoverSelectionView: SettingPopoverSelectionView {

    var options: [String]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension HandshakePopoverSelectionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else {
            fatalError("no transport available")
        }
        cell.textLabel?.style(style: cellTextStyle)

        cell.textLabel?.text = options[indexPath.row].description
        cell.textLabel?.accessibilityLabel = options[indexPath.row].description
                
        Theme.current.applySecondaryBackground(cell)
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let value = options[indexPath.row]
        
        settingsDelegate.updateHandshake(handshake: value)
        Macros.postNotification(.PIASettingsHaveChanged)
        
        currentPopover.dismiss()
    }

}


