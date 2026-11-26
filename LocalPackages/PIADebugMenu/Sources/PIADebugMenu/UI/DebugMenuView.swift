import StoreKit
import SwiftUI

// MARK: - DebugMenuView

@available(iOS 16, tvOS 17, *)
public struct DebugMenuView: View {
    @StateObject private var store: DebugMenuStore

    private var state: DebugMenu.State { store.state }

    public var body: some View {
        mainContent
            .alert(item: store.binding(\.alert) { _ in .alertDismissed }) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            #if os(iOS)
                .manageSubscriptionsSheet(
                    isPresented: storeKitBinding(\.isPresentingManageSubscriptions) { .manageSubscriptionsPresented($0) }
                )
                .refundRequestSheet(
                    for: state.refundTransactionId,
                    isPresented: storeKitBinding(\.isRefundSheetPresented) { .refundSheetPresented($0) }
                ) { @MainActor result in
                    store.send(.refundFinished(DebugMenu.RefundOutcome(result)))
                }
                .sheet(isPresented: store.binding(\.isTransactionPickerPresented) { .transactionPickerPresented($0) }) {
                    List {
                        Section("Select a transaction to refund") {
                            ForEach(state.availableTransactions) { transaction in
                                Button(transaction.productID) {
                                    store.send(.transactionSelected(transaction))
                                }
                            }
                        }
                    }
                }
            #endif
            .navigationTitle("Debug Menu")
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                store.send(.onDisappear)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }

                #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(
                            item: DebugExportFile(
                                content: state.exportContent,
                                filename: "debug_\(Int(Date().timeIntervalSince1970)).txt"
                            ),
                            preview: SharePreview("Debug Export")
                        ) {
                            Text("Export All")
                        }
                    }
                #endif
            }
            #if os(tvOS)
                .background(Color.black.ignoresSafeArea())
            #endif
    }

    /// StoreKit's sheet modifiers read and write their `isPresented` binding from a cooperative-pool
    /// thread, not the main actor. `store.binding` — or any closure formed inside this main-actor view,
    /// even one marked `@Sendable` — is main-actor isolated, and Swift 6 traps when it runs there.
    ///
    /// So the binding is built in a `nonisolated` context: the getter returns the value captured when
    /// `body` ran (a state change re-runs `body`, so it stays current), and the setter hops to the main
    /// actor before dispatching.
    private func storeKitBinding(
        _ keyPath: KeyPath<DebugMenu.State, Bool>,
        send action: @escaping @Sendable (Bool) -> DebugMenu.Action
    ) -> Binding<Bool> {
        Self.offMainBinding(isPresented: store.state[keyPath: keyPath], store: store, send: action)
    }

    private nonisolated static func offMainBinding(
        isPresented: Bool,
        store: DebugMenuStore,
        send action: @escaping @Sendable (Bool) -> DebugMenu.Action
    ) -> Binding<Bool> {
        Binding(
            get: { isPresented },
            set: { newValue in
                Task { @MainActor in store.send(action(newValue)) }
            }
        )
    }

    @ViewBuilder
    private var closeButton: some View {
        #if os(iOS)
            if #available(iOS 26, *) {
                Button(role: .close) { store.send(.closeTapped) }
            } else {
                Button("Close") { store.send(.closeTapped) }
            }
        #else
            Button("Close") { store.send(.closeTapped) }
        #endif
    }

    @ViewBuilder
    private var mainContent: some View {
        #if os(tvOS)
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    appInfoSection
                        .focusable()
                    vpnSection
                        .focusable()
                    connectionConfigurationsSection
                        .focusable()
                    accountSection
                        .focusable()
                    receiptSection
                        .focusable()
                    logsSection
                        .focusable()
                    tunnelLogSection
                        .focusable()
                    supportSection
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
            }
        #else
            List {
                appInfoSection
                vpnSection
                connectionConfigurationsSection
                accountSection
                receiptSection
                logsSection
                tunnelLogSection
                subscriptionSection
                supportSection
            }
        #endif
    }

    // MARK: - Sections

    private var appInfoSection: some View {
        DebugSection("App Info") {
            DebugInfoRow(label: "Version", value: state.appInfo.version)
            DebugInfoRow(label: "Environment", value: state.appInfo.environment)
            DebugInfoRow(label: "Base URL", value: state.appInfo.baseURL)
        }
    }

    private var vpnSection: some View {
        DebugSection("VPN") {
            DebugInfoRow(label: "Status", value: state.vpnStatus)
            DebugInfoRow(label: "Connected Via", value: state.connectedVia)
            DebugInfoRow(label: "Protocol", value: state.liveInfo.protocolName)
            DebugInfoRow(label: "Local IP", value: state.liveInfo.publicIP)
            DebugInfoRow(label: "VPN IP (PIA's Endpoint)", value: state.liveInfo.vpnIP)
            DebugInfoRow(label: "VPN IP (ipify)", value: state.ipifyIP)
        }
    }

    /// The endpoints the tunnel will attempt, in attempt order. Empty while the tunnel is down —
    /// the extension process, which owns the list, only exists while connecting or connected.
    private var connectionConfigurationsSection: some View {
        DebugSection("Connection Configurations") {
            if state.connectionConfigurations.isEmpty {
                DebugInfoRow(label: "Endpoints", value: "Tunnel not running")
            } else {
                // Keyed by position: the same endpoint can legitimately repeat across pecking-order
                // steps, so the configuration itself is not a stable identity.
                ForEach(Array(state.connectionConfigurationsPreview.enumerated()), id: \.offset) { _, configuration in
                    DebugInfoRow(
                        label: configuration.vpnProtocol,
                        value: state.endpoint(of: configuration)
                    )
                }
            }
        }
    }

    private var accountSection: some View {
        DebugSection("Account and Subscription") {
            DebugInfoRow(label: "Username", value: state.username)
            DebugInfoRow(label: "Plan", value: state.plan)
            DebugInfoRow(label: "Product ID", value: state.productId)
            DebugInfoRow(label: "Expiration Date", value: state.expiration)
            DebugInfoRow(label: "Is Expired", value: state.isExpired)
            DebugInfoRow(label: "Is Renewable", value: state.isRenewable)
            DebugInfoRow(label: "Is Recurring", value: state.isRecurring)
        }
    }

    private var receiptSection: some View {
        DebugSection("Transaction (JWS)") {
            if let transactionJWS = state.transactionJWS {
                let preview = String(transactionJWS.prefix(300)) + "..."
                VStack(alignment: .leading, spacing: 2) {
                    Text("Transaction JWS (preview)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(preview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                #if os(tvOS)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                #else
                    .padding(.vertical, 2)
                #endif

                #if os(iOS)
                    ShareLink(
                        item: DebugExportFile(
                            content: transactionJWS,
                            filename: "transaction_\(Int(Date().timeIntervalSince1970)).txt"
                        ),
                        preview: SharePreview("Transaction JWS")
                    ) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                #endif
            } else {
                DebugInfoRow(label: "Transaction", value: "Not available")
            }
        }
    }

    private var logsSection: some View {
        DebugSection("App Logs") {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recent logs (newest on top, last \(DebugMenu.previewLineCount) lines)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal) {
                    Text(state.logPreview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            #if os(tvOS)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            #else
                .padding(.vertical, 2)
            #endif

            #if os(iOS)
                ShareLink(
                    item: DebugExportFile(
                        content: state.logSnapshot,
                        filename: "logs_\(Int(Date().timeIntervalSince1970)).txt"
                    ),
                    preview: SharePreview("App Logs")
                ) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            #endif
        }
    }

    private var tunnelLogSection: some View {
        DebugSection("Tunnel Log") {
            VStack(alignment: .leading, spacing: 2) {
                Text("Live tunnel-extension log (newest on top, last \(DebugMenu.previewLineCount) lines)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal) {
                    Text(state.tunnelLogPreview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            #if os(tvOS)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            #else
                .padding(.vertical, 2)
            #endif

            #if os(iOS)
                ShareLink(
                    item: DebugExportFile(
                        content: state.tunnelLogSnapshot,
                        filename: "tunnel_logs_\(Int(Date().timeIntervalSince1970)).txt"
                    ),
                    preview: SharePreview("Tunnel Log")
                ) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            #endif
        }
    }

    private var subscriptionSection: some View {
        DebugSection("Subscription") {
            Button("Manage Subscriptions") {
                store.send(.manageSubscriptionsTapped)
            }
            Button {
                store.send(.refundTapped)
            } label: {
                if state.isLoadingRefundTransaction {
                    HStack {
                        ProgressView()
                        Text("Looking up transaction...")
                    }
                } else {
                    Text("Test Refund Request")
                }
            }
            .disabled(state.isLoadingRefundTransaction)
        }
    }

    private var supportSection: some View {
        DebugSection("Support") {
            Button {
                store.send(.sendReportTapped)
            } label: {
                if state.isSendingReport {
                    HStack {
                        ProgressView()
                        Text("Sending...")
                    }
                } else {
                    Text("Send to Support (CSI)")
                }
            }
            .disabled(state.isSendingReport)
        }
    }

    // MARK: - Init

    /// Seeds the static and cheap values up front so the first frame is not blank; the rest arrives
    /// once the screen appears.
    @MainActor
    public init(dependencies: DebugMenu.Dependencies) {
        self.init(
            initialState: DebugMenu.State(
                appInfo: dependencies.appInfo(),
                account: dependencies.currentAccount(),
                liveInfo: dependencies.liveInfo(),
                logSnapshot: dependencies.logs()
            ),
            dependencies: dependencies
        )
    }

    init(initialState: DebugMenu.State, dependencies: DebugMenu.Dependencies) {
        _store = StateObject(
            wrappedValue: DebugMenuStore(
                initialState: initialState,
                dependencies: dependencies
            ))
    }
}

#if os(iOS)
    extension DebugMenu.RefundOutcome {
        init(_ result: Result<StoreKit.Transaction.RefundRequestStatus, StoreKit.Transaction.RefundRequestError>) {
            switch result {
            case .success(.success):
                self = .submitted
            case .success:
                self = .notSubmitted
            case .failure(let error):
                self = .failed(message: error.localizedDescription)
            }
        }
    }
#endif

// MARK: - Preview

#if DEBUG
    extension DebugMenu.Dependencies {
        static var preview: Self {
            Self(
                appInfo: { .init(version: "4.0.0 (1234)", environment: "staging", baseURL: "https://example.com") },
                currentAccount: {
                    .init(
                        username: "p1234567",
                        plan: "yearly",
                        productId: "com.example.yearly",
                        expiration: "Oct 19, 2027",
                        isExpired: false,
                        isRenewable: true,
                        isRecurring: true
                    )
                },
                liveInfo: { .init(protocolName: "WireGuard", publicIP: "203.0.113.1", vpnIP: "198.51.100.7") },
                logs: { "First log line\nSecond log line" },
                tunnelLog: { nil },
                vpnConnection: { .unknown },
                ipifyAddress: { "198.51.100.7" },
                connectionConfigurations: { [] },
                connectionConfigurationChanges: { AsyncStream { $0.finish() } },
                pollTicks: { AsyncStream { $0.finish() } },
                entitlementJWS: { nil },
                currentEntitlements: { [] },
                submitReport: { _, _ in .sent(reportID: "PREVIEW") },
                emit: { _ in }
            )
        }
    }

    @available(iOS 16, tvOS 17, *)
    #Preview {
        // If preview doesn't work, enable
        // Editor > Canvas > Use Legacy Previews Execution
        NavigationStack {
            DebugMenuView(dependencies: .preview)
        }
    }
#endif
