//
//  RefreshServersLatencyUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 3/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine

protocol RefreshServersLatencyUseCaseType {
    var statePublisher: Published<RefreshServersLatencyUseCase.State>.Publisher { get }
    func callAsFunction()
    func stop()
}

class RefreshServersLatencyUseCase: RefreshServersLatencyUseCaseType {
    
    private let client: ClientType
    private let serverProvider: ServerProviderType
    private let notificationCenter: NotificationCenterType
    private let connectionStateMonitor: ConnectionStateMonitorType
    private var cancellables = Set<AnyCancellable>()
    
    private let refreshLatencyAfterMinutes = 5
    private let refreshLatencyTimerInSeconds: TimeInterval = 300
    private(set) var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    
    enum State: Equatable {
        case none
        case updating
        case updated(Date?)
        
        var isUpdated: Bool {
            switch self {
            case .updated(_):
                return true
            case .none, .updating:
                return false
            }
        }
    }
    
    @Published var state: State = .none
    var statePublisher: Published<State>.Publisher {
        $state
    }
    
    init(client: ClientType, serverProvider: ServerProviderType, notificationCenter: NotificationCenterType, connectionStateMonitor: ConnectionStateMonitorType) {
        self.client = client
        self.serverProvider = serverProvider
        self.notificationCenter = notificationCenter
        self.connectionStateMonitor = connectionStateMonitor
        
        subscribeToServersPingingUpdates()
    }
    
    func callAsFunction() {
        refreshLatencyIfNeeded()
        self.timer = Timer.publish(every: refreshLatencyTimerInSeconds, on: .main, in: .common).autoconnect()
        timer?.sink(receiveValue: {[weak self] newVal in
            self?.refreshLatencyIfNeeded()
        }).store(in: &cancellables)
    }
    
    func stop() {
        self.timer = nil
        self.state = .none
    }
    
    private func refreshLatencyIfNeeded() {
        let currentConnectionState = connectionStateMonitor.currentConnectionState
        
        switch (currentConnectionState, state) {
        case (.disconnected, .none):
            refreshLatency()
        case (.disconnected, .updated(let date)):
            if shoudRefreshLatency(after: date) {
                refreshLatency()
            }
        default:
            break

        }
        
        func refreshLatency() {
            state = .updating
            let servers = serverProvider.currentServersType
            client.ping(servers: servers)
        }
        
    }
}

// MARK: - NotificationCenter subscription

extension RefreshServersLatencyUseCase {
    
    private func nowInUTCTimezone() -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        guard let utcTimezone = TimeZone(identifier: "UTC") else { return nil }
        
        calendar.timeZone = utcTimezone
        let now = Date()
        let nowInUTC = calendar.date(byAdding: .second, value: 0, to: now)
        return nowInUTC
    }
    
    private func shoudRefreshLatency(after lastRefreshed: Date?) -> Bool {
        
        var calendar = Calendar(identifier: .gregorian)
        guard let utcTimezone = TimeZone(identifier: "UTC"),
        let lastRefreshed else { return true }
        calendar.timeZone = utcTimezone
        
        guard let refreshDeadline = calendar.date(byAdding: .minute, value: self.refreshLatencyAfterMinutes, to: lastRefreshed),
              let nowInUTCTimezone = nowInUTCTimezone() else { return true }
        
        if nowInUTCTimezone > refreshDeadline {
            return true
        }
        
        return false
    }
    
    private func subscribeToServersPingingUpdates() {
        notificationCenter.publisher(for: .PIADaemonsDidPingServers, object: nil)
            .receive(on: RunLoop.main)
            .map {[weak self] _ in
                return State.updated(self?.nowInUTCTimezone())
            }.assign(to: &$state)
    }
    
}
