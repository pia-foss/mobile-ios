//
//  ProtocolSettingsViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 18/5/21.
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
import Popover
import SwiftyBeaver
import PIALibrary
import TunnelKit

class ProtocolSettingsViewController: PIABaseSettingsViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var protocolPopover: Popover!
    private var transportPopover: Popover!
    private var portsPopover: Popover!
    private var dataEncryptionPopover: Popover!
    private var handshakePopover: Popover!
    
    static let AUTOMATIC_SOCKET = "automatic"
    static let AUTOMATIC_PORT: UInt16 = 0

    private lazy var switchSmallPackets = UISwitch()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
                
        tableView.delegate = self
        tableView.dataSource = self

        let options = [
          .type(.auto),
          .cornerRadius(10),
          .animationIn(0.3),
          .blackOverlayColor(UIColor.black.withAlphaComponent(0.1)),
          .arrowSize(CGSize.zero)
          ] as [PopoverOption]
        self.protocolPopover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        self.transportPopover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        self.portsPopover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        self.dataEncryptionPopover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        self.handshakePopover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        
        switchSmallPackets.addTarget(self, action: #selector(toggleSmallPackets(_:)), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettings), name: .PIASettingsHaveChanged, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Settings.Section.protocols)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }
    
    private func heightForOptions(_ options: [Any]) -> Int {
        return 44 * options.count
    }

    private func showProtocolOptions(sender: UITableViewCell) {
        
        let options = [
            IKEv2Profile.vpnType,
            PIAWGTunnelProfile.vpnType,
            PIATunnelProfile.vpnType,
        ]
        
        let width = self.view.frame.width / 2
        let height = heightForOptions(options) //Default height * 3 for 3 protocols
        let optionsView = ProtocolPopoverSelectionView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
        optionsView.pendingPreferences = self.pendingPreferences
        optionsView.settingsDelegate = self.settingsDelegate
        optionsView.currentPopover = protocolPopover
        optionsView.protocols = options
        protocolPopover.show(optionsView, fromView: sender)

    }
    
    private func showTransportOptions(sender: UITableViewCell) {
        
        let options: [String] = [
            ProtocolSettingsViewController.AUTOMATIC_SOCKET,
            SocketType.udp.rawValue,
            SocketType.tcp.rawValue
        ]

        let width = self.view.frame.width / 2
        let height = heightForOptions(options) //Default height * 3 for 3 protocols
        let optionsView = TransportPopoverSelectionView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
        optionsView.pendingPreferences = self.pendingPreferences
        optionsView.settingsDelegate = self.settingsDelegate
        optionsView.currentPopover = protocolPopover
        optionsView.options = options
        protocolPopover.show(optionsView, fromView: sender)

    }

    private func showPortOptions(sender: UITableViewCell) {

        var options = [UInt16]()
        
        if let socketType = settingsDelegate.pendingOpenVPNSocketType {
            let availablePorts = Client.providers.serverProvider.currentServersConfiguration.ovpnPorts
            options = (socketType == .udp) ? availablePorts.udp : availablePorts.tcp
        }
        
        options.insert(Self.AUTOMATIC_PORT, at: 0)
        
        let width = self.view.frame.width / 2
        let height = heightForOptions(options) //Default height * 3 for 3 protocols
        let optionsView = PortPopoverSelectionView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
        optionsView.pendingPreferences = self.pendingPreferences
        optionsView.settingsDelegate = self.settingsDelegate
        optionsView.currentPopover = portsPopover
        optionsView.options = options
        portsPopover.show(optionsView, fromView: sender)

    }
    
    private func showDataEncryptionOptions(sender: UITableViewCell) {
        
        var options = [String]()
        
        if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
            
            options.append(contentsOf: [
                OpenVPN.Cipher.aes128gcm.description,
                OpenVPN.Cipher.aes256gcm.description,
            ])

        } else if pendingPreferences.vpnType == IKEv2Profile.vpnType {
            options.append(contentsOf: IKEv2EncryptionAlgorithm.allValues().map {$0.rawValue})
        }

        let width = self.view.frame.width / 2
        let height = heightForOptions(options)
        let optionsView = DataEncryptionPopoverSelectionView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
        optionsView.pendingPreferences = self.pendingPreferences
        optionsView.settingsDelegate = self.settingsDelegate
        optionsView.currentPopover = dataEncryptionPopover
        optionsView.options = options
        dataEncryptionPopover.show(optionsView, fromView: sender)
        
    }
    
    private func showHandshakeOptions(sender: UITableViewCell) {
        
        var options = IKEv2EncryptionAlgorithm.defaultAlgorithm.integrityAlgorithms().map{$0.description()}

        if let encryptionAlgorithm = IKEv2EncryptionAlgorithm(rawValue: pendingPreferences.ikeV2EncryptionAlgorithm) {
            options = encryptionAlgorithm.integrityAlgorithms().map{$0.description()}
        }

        let width = self.view.frame.width / 2
        let height = 44 * options.count
        let optionsView = HandshakePopoverSelectionView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
        optionsView.pendingPreferences = self.pendingPreferences
        optionsView.settingsDelegate = self.settingsDelegate
        optionsView.currentPopover = handshakePopover
        optionsView.options = options
        handshakePopover.show(optionsView, fromView: sender)
        
    }
    
    @objc private func toggleSmallPackets(_ sender: UISwitch) {
        if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
            AppPreferences.shared.wireGuardUseSmallPackets = sender.isOn
        } else if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
            AppPreferences.shared.useSmallPackets = sender.isOn
        } else if pendingPreferences.vpnType == IKEv2Profile.vpnType {
            AppPreferences.shared.ikeV2UseSmallPackets = sender.isOn
            pendingPreferences.ikeV2PacketSize = sender.isOn ? AppConstants.IKEv2PacketSize.defaultPacketSize : AppConstants.IKEv2PacketSize.highPacketSize
        }
        settingsDelegate.savePreferences()
    }

    @objc private func reloadSettings() {
        tableView.reloadData()
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Settings.Section.general)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        tableView.reloadData()
        protocolPopover?.dismiss()
        transportPopover?.dismiss()
        portsPopover?.dismiss()
        dataEncryptionPopover?.dismiss()
        handshakePopover?.dismiss()
    }

}

extension ProtocolSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
            return ProtocolsSections.all().count
        } else {
            return [ProtocolsSections.protocolSelection, ProtocolsSections.dataEncryption, ProtocolsSections.handshake, ProtocolsSections.useSmallPackets].count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Cells.footer) {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.style(style: TextStyle.textStyle21)
            cell.backgroundColor = .clear
            cell.textLabel?.text =  L10n.Settings.Small.Packets.description
            return cell
        }
        return nil

    }

    
    fileprivate func configure(_ cell: UITableViewCell, forSection section: ProtocolsSections?) {
        switch section {
        case .protocolSelection:
            cell.detailTextLabel?.text = pendingPreferences.vpnType.vpnProtocol
        case .transport:
            cell.detailTextLabel?.text = settingsDelegate.pendingOpenVPNSocketType?.rawValue ?? L10n.Global.automatic
        case .remotePort:
            if let port = settingsDelegate.pendingOpenVPNConfiguration.currentPort, port != ProtocolSettingsViewController.AUTOMATIC_PORT {
                cell.detailTextLabel?.text = port.description
            } else {
                cell.detailTextLabel?.text = L10n.Global.automatic
            }
        case .dataEncryption:
            
            if pendingPreferences.vpnType == PIATunnelProfile.vpnType, let cipher = settingsDelegate.pendingOpenVPNConfiguration.cipher {
                cell.detailTextLabel?.text = cipher.description
            } else if pendingPreferences.vpnType == IKEv2Profile.vpnType {
                
                guard Flags.shared.enablesEncryptionSettings else {
                    break
                }
                
                if let encryptionAlgorithm = IKEv2EncryptionAlgorithm(rawValue: pendingPreferences.ikeV2EncryptionAlgorithm) {
                    cell.detailTextLabel?.text = encryptionAlgorithm.rawValue
                } else {
                    cell.detailTextLabel?.text = IKEv2EncryptionAlgorithm.defaultAlgorithm.rawValue
                }
                
            } else if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                cell.detailTextLabel?.text = "ChaCha20"
                cell.accessoryType = .none
            }
        case .handshake:
            if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
                cell.detailTextLabel?.text = AppPreferences.shared.piaHandshake.description
                cell.accessoryType = .none
            } else if pendingPreferences.vpnType == IKEv2Profile.vpnType {
                cell.detailTextLabel?.text = IKEv2IntegrityAlgorithm.objectIdentifyBy(name: pendingPreferences.ikeV2IntegrityAlgorithm).rawValue
            } else if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                cell.detailTextLabel?.text = "Noise_IK"
                cell.accessoryType = .none
            }
        case .useSmallPackets:
            cell.textLabel?.text = L10n.Settings.Small.Packets.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchSmallPackets
            cell.selectionStyle = .none
            if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
                switchSmallPackets.isOn = AppPreferences.shared.useSmallPackets
            } else if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                switchSmallPackets.isOn = AppPreferences.shared.wireGuardUseSmallPackets
            } else if pendingPreferences.vpnType == IKEv2Profile.vpnType {
                switchSmallPackets.isOn = AppPreferences.shared.ikeV2UseSmallPackets
            }
            
        default:
            cell.detailTextLabel?.text = ""
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default
        cell.detailTextLabel?.text = nil

        var section: ProtocolsSections!
        if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
            section = ProtocolsSections.all()[indexPath.row]
        } else {
            section = [ProtocolsSections.protocolSelection, ProtocolsSections.dataEncryption, ProtocolsSections.handshake, ProtocolsSections.useSmallPackets][indexPath.row]
        }

        cell.textLabel?.text = section.localizedTitleMessage()

        configure(cell, forSection: section)

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

    fileprivate func select(_ cell: UITableViewCell, forSection section: ProtocolsSections?) {
        switch section {
        case .protocolSelection:
            showProtocolOptions(sender: cell)
        case .transport:
            showTransportOptions(sender: cell)
        case .remotePort:
            showPortOptions(sender: cell)
        case .dataEncryption:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            if pendingPreferences.vpnType == PIATunnelProfile.vpnType || pendingPreferences.vpnType == IKEv2Profile.vpnType {
                showDataEncryptionOptions(sender: cell)
            }
        case .handshake:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            if pendingPreferences.vpnType == IKEv2Profile.vpnType {
                showHandshakeOptions(sender: cell)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var section: ProtocolsSections!
        if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
            section = ProtocolsSections.all()[indexPath.row]
        } else {
            section = [ProtocolsSections.protocolSelection, ProtocolsSections.dataEncryption, ProtocolsSections.handshake, ProtocolsSections.useSmallPackets][indexPath.row]
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)

        select(cell, forSection: section)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}
