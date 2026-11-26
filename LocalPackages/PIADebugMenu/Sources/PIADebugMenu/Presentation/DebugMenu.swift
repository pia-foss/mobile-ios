import Foundation
import PIALibrary

public enum DebugMenu {}

extension DebugMenu {

    /// Both log sections show only the tail of the snapshot — the full content is still one tap
    /// away via Export. Unbounded 1000-line monospaced `Text` inside a scrolling `List` is expensive
    /// to lay out on every re-render and was a source of scroll jank.
    static let previewLineCount = 25

    /// What the build is and where it points. Fixed for the lifetime of the process.
    struct AppInfo: Equatable, Sendable {
        var version: String
        var environment: String
        var baseURL: String
    }

    /// The logged-in account, already formatted for display.
    struct Account: Equatable, Sendable {
        var username: String
        var plan: String
        var productId: String
        var expiration: String
        var isExpired: Bool
        var isRenewable: Bool
        var isRecurring: Bool
    }

    /// VPN values PIA itself reports, re-read on every poll.
    struct LiveInfo: Equatable, Sendable {
        /// Includes the active obfuscation, e.g. "WireGuard (amnezia)".
        var protocolName: String
        var publicIP: String
        var vpnIP: String
    }

    /// A StoreKit entitlement, reduced to what the refund flow needs.
    struct RefundableTransaction: Equatable, Identifiable, Sendable {
        var id: UInt64
        var productID: String
    }

    struct Alert: Hashable, Identifiable, Sendable {
        var title: String
        var message: String

        var id: Self { self }
    }

    /// How submitting the debug report to CSI ended.
    enum ReportResult: Equatable, Sendable {
        case sent(reportID: String)
        case failed
    }

    /// How the App Store refund sheet ended.
    enum RefundOutcome: Equatable, Sendable {
        case submitted
        /// The sheet closed without a request, e.g. the user cancelled.
        case notSubmitted
        case failed(message: String)
    }

    struct State: Equatable {
        var appInfo: AppInfo
        var account: Account?
        var liveInfo: LiveInfo
        var vpnConnection: VPNConnectionState = .unknown
        var ipifyIP: String = "—"
        var connectionConfigurations: [PIAConnectionConfiguration] = []
        var logSnapshot: String
        var tunnelLogSnapshot: String = ""
        var isFetchingTunnelLog = false
        var transactionJWS: String?
        var isSendingReport = false
        var alert: Alert?
        var isPresentingManageSubscriptions = false
        var isLoadingRefundTransaction = false
        var refundTransactionId: UInt64 = 0
        var isRefundSheetPresented = false
        var availableTransactions: [RefundableTransaction] = []
        var isTransactionPickerPresented = false
    }

    enum Action: Equatable {
        // Lifecycle and data
        case onAppear
        case onDisappear
        case pollTick
        case logsUpdated(String)
        case accountUpdated(Account?)
        case liveInfoUpdated(LiveInfo)
        case vpnConnectionUpdated(VPNConnectionState)
        case tunnelLogUpdated(String?)
        case ipifyResolved(String?)
        case entitlementLoaded(String?)
        case connectionConfigurationsUpdated([PIAConnectionConfiguration])

        // User
        case closeTapped
        case manageSubscriptionsTapped
        case sendReportTapped
        case reportFinished(ReportResult)
        case refundTapped
        case refundTransactionsLoaded([RefundableTransaction])
        case transactionSelected(RefundableTransaction)
        case refundFinished(RefundOutcome)
        case alertDismissed

        // Bindings
        case manageSubscriptionsPresented(Bool)
        case refundSheetPresented(Bool)
        case transactionPickerPresented(Bool)
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        case dismiss
    }

    /// Built by `live(emit:)`; tests reach the memberwise init through `@testable`.
    public struct Dependencies: Sendable {
        var appInfo: @MainActor () -> AppInfo
        var currentAccount: @MainActor () -> Account?
        var liveInfo: @MainActor () -> LiveInfo
        var logs: @MainActor () -> String
        /// Answered by the tunnel extension; `nil` when it is not running or the IPC timed out.
        var tunnelLog: @MainActor () async -> String?
        var vpnConnection: @MainActor () async -> VPNConnectionState
        /// `nil` when the lookup fails — offline, blocked, or timed out.
        var ipifyAddress: @MainActor () async -> String?
        var connectionConfigurations: @MainActor () async -> [PIAConnectionConfiguration]
        /// Fires whenever the tunnel may have built a new batch of configurations.
        var connectionConfigurationChanges: @MainActor () -> AsyncStream<Void>
        /// Fires immediately, then once per refresh interval.
        var pollTicks: @MainActor () -> AsyncStream<Void>
        var entitlementJWS: @MainActor () async -> String?
        var currentEntitlements: @MainActor () async -> [RefundableTransaction]
        var submitReport: @MainActor (_ status: String, _ connectedVia: String) async -> ReportResult
        var emit: @MainActor (Output) -> Void
    }
}
