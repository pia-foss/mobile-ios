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

final class Bootstrapper: BootstraperType {
    let setupEnvironment: (() -> Void)
    let setupDebuggingConsole: (() -> Void)
    let loadDataBase: (() -> Void)
    let cleanCurrentAccount: (() -> Void)
    let migrateNMT: (() -> Void)
    let setupLatestRegionList: (() -> Void)
    let setupConfiguration: (() -> Void)
    let setupPreferences: (() -> Void)
    let acceptDataSharing: (() -> Void)
    let dependencyBootstrap: (() -> Void)
    let renewalDIPToken: (() -> Void)
    let setupExceptionHandler: (() -> Void)
    let startConnectionStateMonitor: (() -> Void)
    let startCachingLicenses: (() -> Void)

    init(
        setupEnvironment: @escaping () -> Void,
        setupDebuggingConsole: @escaping () -> Void,
        loadDataBase: @escaping () -> Void,
        cleanCurrentAccount: @escaping () -> Void,
        migrateNMT: @escaping () -> Void,
        setupLatestRegionList: @escaping () -> Void,
        setupConfiguration: @escaping () -> Void,
        setupPreferences: @escaping () -> Void,
        acceptDataSharing: @escaping () -> Void,
        dependencyBootstrap: @escaping () -> Void,
        renewalDIPToken: @escaping () -> Void,
        setupExceptionHandler: @escaping () -> Void,
        startConnectionStateMonitor: @escaping () -> Void,
        startCachingLicenses: @escaping () -> Void
    ) {
        self.setupEnvironment = setupEnvironment
        self.setupDebuggingConsole = setupDebuggingConsole
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
        self.startConnectionStateMonitor = startConnectionStateMonitor
        self.startCachingLicenses = startCachingLicenses
    }
    
    func callAsFunction() {
        setupEnvironment()
        setupDebuggingConsole()
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
        startConnectionStateMonitor()
        startCachingLicenses()
    }
}
