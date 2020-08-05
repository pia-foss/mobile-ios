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

class NetworkRuleOptionView: UIView {

    private let cellReuseIdentifier = "cell"
    weak var currentPopover: Popover!
    var currentType: NMTType!
    
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.textLabel?.style(style: Theme.current.palette.appearance == .dark ? TextStyle.textStyle6 : TextStyle.textStyle7)

        switch indexPath.row {
        case NMTRules.alwaysConnect.rawValue:
            cell.textLabel?.text = "Always Connect VPN"
            cell.accessoryView = UIImageView(image: Asset.Piax.Nmt.iconNmtConnect.image.withRenderingMode(.alwaysTemplate))
        case NMTRules.alwaysDisconnect.rawValue:
            cell.textLabel?.text = "Always Disconnect VPN"
            cell.accessoryView = UIImageView(image: Asset.Piax.Nmt.iconDisconnect.image.withRenderingMode(.alwaysTemplate))
        default:
            cell.textLabel?.text = "Retain VPN State"
            cell.accessoryView = UIImageView(image: Asset.Piax.Nmt.iconRetain.image.withRenderingMode(.alwaysTemplate))
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
        var rules = preferences.nmtGenericRules
        
        switch indexPath.row {
        case NMTRules.alwaysConnect.rawValue:
            rules[currentType.rawValue] = NMTRules.alwaysConnect.rawValue
        case NMTRules.alwaysDisconnect.rawValue:
            rules[currentType.rawValue] = NMTRules.alwaysDisconnect.rawValue
        default:
            rules[currentType.rawValue] = NMTRules.retainState.rawValue
        }
        
        preferences.nmtGenericRules = rules
        preferences.commit()

        NotificationCenter.default.post(name: .RefreshNMTRules, object: nil)
        currentPopover.dismiss()
    }

}
