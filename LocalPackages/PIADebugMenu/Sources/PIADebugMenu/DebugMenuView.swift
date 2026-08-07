import SwiftUI

// MARK: - DebugMenuView

@available(iOS 16, tvOS 17, *)
public struct DebugMenuView: View {
    private let onDismiss: () -> Void
    @StateObject private var viewModel = DebugMenuViewModel()

    public var body: some View {
        mainContent
            .alert(item: $viewModel.reportResult) { result in
                Alert(
                    title: Text(result.title),
                    message: Text(result.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            #if os(iOS)
                .manageSubscriptionsSheet(isPresented: $viewModel.isPresentingManageSubscriptions)
                .refundRequestSheet(for: viewModel.refundTransactionId, isPresented: $viewModel.isRefundSheetPresented) {
                    @MainActor result in
                    viewModel.handleRefundResult(result)
                }
                .sheet(isPresented: $viewModel.isTransactionPickerPresented) {
                    List {
                        Section("Select a transaction to refund") {
                            ForEach(viewModel.availableTransactions, id: \.id) { transaction in
                                Button(transaction.productID) {
                                    viewModel.selectTransaction(transaction)
                                }
                            }
                        }
                    }
                }
            #endif
            .navigationTitle("Debug Menu")
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", action: onDismiss)
                }

                #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(
                            item: DebugExportFile(
                                content: viewModel.buildExportContent(),
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

    @ViewBuilder
    private var mainContent: some View {
        #if os(tvOS)
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    appInfoSection
                        .focusable()
                    vpnSection
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
            DebugInfoRow(label: "Version", value: viewModel.appVersion)
            DebugInfoRow(label: "Environment", value: viewModel.environment)
            DebugInfoRow(label: "Base URL", value: viewModel.baseUrl)
        }
    }

    private var vpnSection: some View {
        DebugSection("VPN") {
            DebugInfoRow(label: "Status", value: viewModel.vpnStatus)
            DebugInfoRow(label: "Connected Via", value: viewModel.connectedVia)
            DebugInfoRow(label: "Protocol", value: viewModel.vpnProtocolName)
            DebugInfoRow(label: "Local IP", value: viewModel.publicIP)
            DebugInfoRow(label: "VPN IP", value: viewModel.vpnIP)
        }
    }

    private var accountSection: some View {
        DebugSection("Account and Subscription") {
            DebugInfoRow(label: "Username", value: viewModel.username)
            DebugInfoRow(label: "Plan", value: viewModel.plan)
            DebugInfoRow(label: "Product ID", value: viewModel.productId)
            DebugInfoRow(label: "Expiration Date", value: viewModel.expirationFormatted)
            DebugInfoRow(label: "Is Expired", value: viewModel.isExpired)
            DebugInfoRow(label: "Is Renewable", value: viewModel.isRenewable)
            DebugInfoRow(label: "Is Recurring", value: viewModel.isRecurring)
        }
    }

    private var receiptSection: some View {
        DebugSection("Transaction (JWS)") {
            if let transactionJWS = viewModel.transactionJWS {
                let preview = String(transactionJWS.value.prefix(300)) + "..."
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
                            content: transactionJWS.value,
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
                Text("Recent logs (newest on top, last \(DebugMenuViewModel.previewLineCount) lines)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal) {
                    Text(viewModel.logPreview)
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
                        content: viewModel.logs,
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
                Text("Live tunnel-extension log (newest on top, last \(DebugMenuViewModel.previewLineCount) lines)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal) {
                    Text(viewModel.tunnelLogPreview)
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
                        content: viewModel.tunnelLogSnapshot,
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
                viewModel.presentManageSubscriptions()
            }
            Button {
                Task {
                    await viewModel.requestRefund()
                }
            } label: {
                if viewModel.isLoadingRefundTransaction {
                    HStack {
                        ProgressView()
                        Text("Looking up transaction...")
                    }
                } else {
                    Text("Test Refund Request")
                }
            }
            .disabled(viewModel.isLoadingRefundTransaction)
        }
    }

    private var supportSection: some View {
        DebugSection("Support") {
            Button {
                Task {
                    await viewModel.sendReportToSupport()
                }
            } label: {
                if viewModel.isSendingReport {
                    HStack {
                        ProgressView()
                        Text("Sending...")
                    }
                } else {
                    Text("Send to Support (CSI)")
                }
            }
            .disabled(viewModel.isSendingReport)
        }
    }

    // MARK: - Init

    public init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }

}

@available(iOS 16, tvOS 17, *)
#Preview {
    // If preview doesn't work, enable
    // Editor > Canvas > Use Legacy Previews Execution
    DebugMenuView()
}
