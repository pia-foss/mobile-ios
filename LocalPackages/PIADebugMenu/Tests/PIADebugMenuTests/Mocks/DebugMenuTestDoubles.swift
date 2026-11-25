import Foundation
import PIALibrary

@testable import PIADebugMenu

@MainActor
final class DebugMenuDependencySpy {
    var account: DebugMenu.Account? = .stub()
    var liveInfo: DebugMenu.LiveInfo = .stub()
    var logs = "log line"
    var tunnelLog: String? = "tunnel line"
    var vpnConnection: VPNConnectionState = .unknown
    var ipifyAddress: String? = "198.51.100.7"
    var connectionConfigurations: [PIAConnectionConfiguration] = []
    var entitlementJWS: String? = "jws"
    var entitlements: [DebugMenu.RefundableTransaction] = []
    var reportResult: DebugMenu.ReportResult = .sent(reportID: "ABC12")

    private(set) var ipifyCallCount = 0
    private(set) var tunnelLogCallCount = 0
    private(set) var entitlementCallCount = 0
    private(set) var submittedReports: [(status: String, connectedVia: String)] = []
    private(set) var emittedOutputs: [DebugMenu.Output] = []

    /// Each `yield()` is one refresh tick. Buffered, so a test can yield before the stream effect
    /// starts listening.
    let ticks: AsyncStream<Void>.Continuation
    private let tickStream: AsyncStream<Void>

    /// Each `yield()` is one connection-configuration change signal.
    let configurationChanges: AsyncStream<Void>.Continuation
    private let configurationChangeStream: AsyncStream<Void>

    init() {
        (tickStream, ticks) = AsyncStream.makeStream()
        (configurationChangeStream, configurationChanges) = AsyncStream.makeStream()
    }

    func makeDependencies() -> DebugMenu.Dependencies {
        .init(
            appInfo: { .stub() },
            currentAccount: { [self] in account },
            liveInfo: { [self] in liveInfo },
            logs: { [self] in logs },
            tunnelLog: { [self] in
                tunnelLogCallCount += 1
                return tunnelLog
            },
            vpnConnection: { [self] in vpnConnection },
            ipifyAddress: { [self] in
                ipifyCallCount += 1
                return ipifyAddress
            },
            connectionConfigurations: { [self] in connectionConfigurations },
            connectionConfigurationChanges: { [configurationChangeStream] in configurationChangeStream },
            pollTicks: { [tickStream] in tickStream },
            entitlementJWS: { [self] in
                entitlementCallCount += 1
                return entitlementJWS
            },
            currentEntitlements: { [self] in entitlements },
            submitReport: { [self] status, connectedVia in
                submittedReports.append((status, connectedVia))
                return reportResult
            },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }

    /// Ends both streams so `TestStore.finish()` doesn't have to cancel them.
    func finishStreams() {
        ticks.finish()
        configurationChanges.finish()
    }
}

extension DebugMenu.State {
    static func stub(
        account: DebugMenu.Account? = .stub(),
        liveInfo: DebugMenu.LiveInfo = .stub(),
        logSnapshot: String = "log line"
    ) -> Self {
        .init(appInfo: .stub(), account: account, liveInfo: liveInfo, logSnapshot: logSnapshot)
    }
}

extension DebugMenu.AppInfo {
    static func stub() -> Self {
        .init(version: "4.0.0 (1234)", environment: "staging", baseURL: "https://example.com")
    }
}

extension DebugMenu.Account {
    static func stub(username: String = "p1234567", isExpired: Bool = false) -> Self {
        .init(
            username: username,
            plan: "yearly",
            productId: "com.example.yearly",
            expiration: "Oct 19, 2027",
            isExpired: isExpired,
            isRenewable: true,
            isRecurring: false
        )
    }
}

extension DebugMenu.LiveInfo {
    static func stub(protocolName: String = "WireGuard", vpnIP: String = "198.51.100.7") -> Self {
        .init(protocolName: protocolName, publicIP: "203.0.113.1", vpnIP: vpnIP)
    }
}

extension DebugMenu.RefundableTransaction {
    static func stub(id: UInt64 = 1, productID: String = "com.example.yearly") -> Self {
        .init(id: id, productID: productID)
    }
}

extension VPNConnectionState {
    static let piaConnected = VPNConnectionState(profileState: .connected, isTunnelActive: true)
}

extension PIAConnectionConfiguration {
    static func stub(vpnProtocol: String = "WireGuard", host: String = "10.0.0.1", port: UInt16 = 1337) -> Self {
        .init(vpnProtocol: vpnProtocol, host: host, port: port)
    }
}
