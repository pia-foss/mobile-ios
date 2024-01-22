//
//  Bootstrapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 17/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol BootstraperType {
    func callAsFunction()
}

class Bootstrapper: BootstraperType {
    var setupDebugginConsole: (() -> Void)
    var loadDataBase: (() -> Void)
    var cleanCurrentAccount: (() -> Void)
    var migrateNMT: (() -> Void)
    var setupLatestRegionList: (() -> Void)
    var setupConfiguration: (() -> Void)
    var setupPreferences: (() -> Void)
    var acceptDataSharing: (() -> Void)
    var dependencyBootstrap: (() -> Void)
    var renewalDIPToken: (() -> Void)
    var setupExceptionHandler: (() -> Void)
    
    init(setupDebugginConsole: @escaping () -> Void, loadDataBase: @escaping () -> Void, cleanCurrentAccount: @escaping () -> Void, migrateNMT: @escaping () -> Void, setupLatestRegionList: @escaping () -> Void, setupConfiguration: @escaping () -> Void, setupPreferences: @escaping () -> Void, acceptDataSharing: @escaping () -> Void, dependencyBootstrap: @escaping () -> Void, renewalDIPToken: @escaping () -> Void, setupExceptionHandler: @escaping () -> Void) {
        self.setupDebugginConsole = setupDebugginConsole
        self.loadDataBase = loadDataBase
        self.cleanCurrentAccount = cleanCurrentAccount
        self.migrateNMT = migrateNMT
        self.setupLatestRegionList = setupLatestRegionList
        self.setupConfiguration = setupConfiguration
        self.setupPreferences = setupPreferences
        self.acceptDataSharing = acceptDataSharing
        self.dependencyBootstrap = dependencyBootstrap
        self.renewalDIPToken = renewalDIPToken
        self.setupExceptionHandler = setupExceptionHandler
    }
    
    func callAsFunction() {
        setupDebugginConsole()
        loadDataBase()
        cleanCurrentAccount()
        migrateNMT()
        setupLatestRegionList()
        setupConfiguration()
        setupPreferences()
        acceptDataSharing()
        dependencyBootstrap()
        renewalDIPToken()
        setupExceptionHandler()
    }
}
