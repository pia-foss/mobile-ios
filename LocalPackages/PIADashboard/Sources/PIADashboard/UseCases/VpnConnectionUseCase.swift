import Combine
import Foundation
import PIALibrary

private let log = PIALogger.logger(for: VpnConnectionUseCase.self)

public protocol VpnConnectionUseCaseType {
    func connect() async throws
    func disconnect() async throws
    func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Error>
}

public enum VpnConnectionIntent: Equatable {
    case none
    case connect
    case disconnect
}

public final class VpnConnectionUseCase: VpnConnectionUseCaseType {

    internal var connectionIntent: CurrentValueSubject<VpnConnectionIntent, Error>

    let serverProvider: ServerProviderType
    let vpnProvider: VPNStatusProviderType
    let vpnStatusMonitor: VPNStatusMonitorType
    private var clientPreferences: ClientPreferencesType
    private var cancellables = Set<AnyCancellable>()

    public init(serverProvider: ServerProviderType, vpnProvider: VPNStatusProviderType, vpnStatusMonitor: VPNStatusMonitorType, clientPreferences: ClientPreferencesType) {
        self.serverProvider = serverProvider
        self.vpnProvider = vpnProvider
        self.vpnStatusMonitor = vpnStatusMonitor
        self.clientPreferences = clientPreferences
        self.connectionIntent = CurrentValueSubject(.none)

        subscribeToVpnStatusState()
    }

    public func connect() async throws {

        log.info("VPN connect requested")
        connectionIntent.send(.connect)

        return try await withCheckedThrowingContinuation { continuation in
            vpnProvider.connect { error in
                if let error = error {
                    log.error("VPN connect failed: \(error.localizedDescription)")
                    self.connectionIntent.send(completion: .failure(error))
                    continuation.resume(throwing: error)
                } else {
                    log.info("VPN connect call succeeded")
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func disconnect() async throws {

        log.info("VPN disconnect requested")
        connectionIntent.send(.disconnect)

        return try await withCheckedThrowingContinuation { continuation in
            vpnProvider.disconnect { error in
                if let error = error {
                    log.error("VPN disconnect failed: \(error.localizedDescription)")
                    self.connectionIntent.send(completion: .failure(error))
                    continuation.resume(throwing: error)
                } else {
                    log.info("VPN disconnect call succeeded")
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Error> {
        return connectionIntent.eraseToAnyPublisher()
    }
}

// MARK: - VPN Status subscription

extension VpnConnectionUseCase {
    func subscribeToVpnStatusState() {
        vpnStatusMonitor.getStatus()
            .receive(on: RunLoop.main)
            .sink { [weak self] newVpnStatus in
                guard let self else { return }

                let currentConnectionIntent = self.connectionIntent.value

                switch (currentConnectionIntent, newVpnStatus) {
                case (.connect, .connected):
                    // Update the lastConnectedRegion when the connection has succeeded
                    self.clientPreferences.lastConnectedServer = try? serverProvider.targetServerType

                    // The vpn connection has succeeded, then put back the connection intent to none
                    log.info("VPN connected successfully")
                    self.connectionIntent.send(.none)
                case (.disconnect, .disconnected):
                    // The vpn disconnect has succeeded, then put back the connection intent to none
                    log.info("VPN disconnected successfully")
                    self.connectionIntent.send(.none)
                default:
                    break

                }
            }.store(in: &cancellables)

    }
}
