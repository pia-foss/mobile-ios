//
//  NetworkRuleOptionView.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 05/08/2020.
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

import UIKit
import PIALibrary
import Popover
import PIADesignSystem

class NetworkRuleOptionView: UIView {

    private let cellReuseIdentifier = "cell"
    weak var currentPopover: Popover!
    var currentType: NMTType!
    var ssid: String!

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
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

extension NetworkRuleOptionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentType == NMTType.trustedNetwork ? 4 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.textLabel?.style(style: Theme.current.palette.appearance == .dark ? TextStyle.textStyle6 : TextStyle.textStyle7)

        switch indexPath.row {
        case NMTRules.alwaysConnect.rawValue:
            cell.textLabel?.text = L10n.Localizable.Network.Management.Tool.Always.connect
            cell.textLabel?.accessibilityLabel = L10n.Localizable.Global.Row.selection + " " + L10n.Localizable.Network.Management.Tool.Always.connect
            cell.accessoryView = UIImageView(image: Asset.Images.Piax.Nmt.iconNmtConnect.image.withRenderingMode(.alwaysTemplate))
        case NMTRules.alwaysDisconnect.rawValue:
            cell.textLabel?.text = L10n.Localizable.Network.Management.Tool.Always.disconnect
            cell.textLabel?.accessibilityLabel = L10n.Localizable.Global.Row.selection + " " + L10n.Localizable.Network.Management.Tool.Always.disconnect
            cell.accessoryView = UIImageView(image: Asset.Images.Piax.Nmt.iconDisconnect.image.withRenderingMode(.alwaysTemplate))
        case NMTRules.retainState.rawValue:
            cell.textLabel?.text = L10n.Localizable.Network.Management.Tool.Retain.state
            cell.textLabel?.accessibilityLabel = L10n.Localizable.Global.Row.selection + " " + L10n.Localizable.Network.Management.Tool.Retain.state
            cell.accessoryView = UIImageView(image: Asset.Images.Piax.Nmt.iconRetain.image.withRenderingMode(.alwaysTemplate))
        default:
            cell.textLabel?.text = L10n.Localizable.Global.remove
            cell.textLabel?.accessibilityLabel = L10n.Localizable.Global.Row.selection + " " + L10n.Localizable.Global.remove
            cell.textLabel?.style(style: TextStyle.textStyle10)
            cell.accessoryView = nil
        }
        
        cell.accessoryView?.tintColor = Theme.current.palette.appearance == .dark ? UIColor.white : UIColor.piaGrey6
        
        Theme.current.applySecondaryBackground(cell)
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let preferences = Client.preferences.editable()

        if currentType != NMTType.trustedNetwork {
            var rules = preferences.nmtGenericRules
            rules[currentType.rawValue] = indexPath.row
            preferences.nmtGenericRules = rules
        } else {
            var rules = preferences.nmtTrustedNetworkRules
            if NMTRules(rawValue: indexPath.row) == nil { //Delete
                rules.removeValue(forKey: ssid)
            } else {
                rules[ssid] = indexPath.row
            }
            preferences.nmtTrustedNetworkRules = rules
            NotificationCenter.default.post(name: .TrustedNetworkAdded, object: nil)
        }
        preferences.commit()

        NotificationCenter.default.post(name: .RefreshNMTRules, object: nil)
        currentPopover.dismiss()
    }

}
