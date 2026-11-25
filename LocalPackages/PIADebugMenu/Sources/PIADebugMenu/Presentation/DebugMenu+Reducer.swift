import CoreArchitecture

extension DebugMenu {

    enum EffectID: Hashable {
        case polling
        case connectionConfigurations
        case ipify
    }

    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            // MARK: Lifecycle

            case .onAppear:
                // Re-appearing restarts the streams under the same ids rather than adding second ones.
                var effects: [Effect<Action>] = [
                    lookUpIpify,
                    polling,
                    observeConnectionConfigurations
                ]
                if state.transactionJWS == nil {
                    effects.append(.task { [dependencies] in .entitlementLoaded(await dependencies.entitlementJWS()) })
                }
                return .merge(effects)

            case .onDisappear:
                return .merge(
                    .cancel(id: EffectID.polling),
                    .cancel(id: EffectID.connectionConfigurations)
                )

            case .pollTick:
                var effects: [Effect<Action>] = [
                    .task { [dependencies] in .logsUpdated(dependencies.logs()) },
                    .task { [dependencies] in .accountUpdated(dependencies.currentAccount()) },
                    .task { [dependencies] in .liveInfoUpdated(dependencies.liveInfo()) },
                    .task { [dependencies] in .vpnConnectionUpdated(await dependencies.vpnConnection()) }
                ]
                // On WireGuard the extension returns only the entries since the previous fetch, so this
                // poll and the fetch performed while submitting a CSI report compete for the same cursor.
                // Ticks are not throttled by the fetch, which can take up to its 5 s timeout, so one
                // still in flight also skips the tick rather than racing it for the cursor.
                if !state.isSendingReport && !state.isFetchingTunnelLog {
                    state.isFetchingTunnelLog = true
                    effects.append(.task { [dependencies] in .tunnelLogUpdated(await dependencies.tunnelLog()) })
                }
                return .merge(effects)

            // MARK: Data

            case .logsUpdated(let logs):
                if logs != state.logSnapshot {
                    state.logSnapshot = logs
                }
                return nil

            case .accountUpdated(let account):
                if account != state.account {
                    state.account = account
                }
                return nil

            case .liveInfoUpdated(let liveInfo):
                if liveInfo != state.liveInfo {
                    state.liveInfo = liveInfo
                }
                return nil

            case .vpnConnectionUpdated(let connection):
                guard connection != state.vpnConnection else { return nil }
                state.vpnConnection = connection
                // Re-asked only when the tunnel actually changes, rather than on every tick: the
                // answer only moves when the egress does, and this is somebody else's service.
                return lookUpIpify

            case .tunnelLogUpdated(let content):
                state.isFetchingTunnelLog = false
                if let content, !content.isEmpty, content != state.tunnelLogSnapshot {
                    state.tunnelLogSnapshot = content
                }
                return nil

            case .ipifyResolved(let address):
                state.ipifyIP = address ?? "unavailable"
                return nil

            case .entitlementLoaded(let jws):
                state.transactionJWS = jws
                return nil

            case .connectionConfigurationsUpdated(let configurations):
                if configurations != state.connectionConfigurations {
                    state.connectionConfigurations = configurations
                }
                return nil

            // MARK: User

            case .closeTapped:
                return .fireAndForget { [dependencies] in dependencies.emit(.dismiss) }

            case .manageSubscriptionsTapped:
                state.isPresentingManageSubscriptions = true
                return nil

            case .sendReportTapped:
                guard !state.isSendingReport else { return nil }
                state.isSendingReport = true
                let status = state.vpnStatus
                let connectedVia = state.connectedVia
                return .task { [dependencies] in
                    .reportFinished(await dependencies.submitReport(status, connectedVia))
                }

            case .reportFinished(let result):
                state.isSendingReport = false
                switch result {
                case .sent(let reportID):
                    state.alert = Alert(
                        title: "Debug information submitted",
                        message: "Report ID: \(reportID)\nPlease note this ID — support will need it to locate your submission."
                    )
                case .failed:
                    state.alert = Alert(
                        title: "Submission failed",
                        message: "Debug information could not be submitted."
                    )
                }
                return nil

            case .refundTapped:
                guard !state.isLoadingRefundTransaction else { return nil }
                state.isLoadingRefundTransaction = true
                return .task { [dependencies] in
                    .refundTransactionsLoaded(await dependencies.currentEntitlements())
                }

            case .refundTransactionsLoaded(let transactions):
                state.isLoadingRefundTransaction = false
                switch transactions.count {
                case 0:
                    state.alert = Alert(
                        title: "No Transaction Found",
                        message: "No active transaction found to request a refund for."
                    )
                case 1:
                    state.refundTransactionId = transactions[0].id
                    state.isRefundSheetPresented = true
                default:
                    state.availableTransactions = transactions
                    state.isTransactionPickerPresented = true
                }
                return nil

            case .transactionSelected(let transaction):
                state.isTransactionPickerPresented = false
                state.refundTransactionId = transaction.id
                state.isRefundSheetPresented = true
                return nil

            case .refundFinished(let outcome):
                switch outcome {
                case .submitted:
                    state.alert = Alert(
                        title: "Refund Requested",
                        message: "Your refund request was submitted to the App Store."
                    )
                case .notSubmitted:
                    break
                case .failed(let message):
                    state.alert = Alert(title: "Refund Request Failed", message: message)
                }
                return nil

            case .alertDismissed:
                state.alert = nil
                return nil

            // MARK: Bindings

            case .manageSubscriptionsPresented(let isPresented):
                state.isPresentingManageSubscriptions = isPresented
                return nil

            case .refundSheetPresented(let isPresented):
                state.isRefundSheetPresented = isPresented
                return nil

            case .transactionPickerPresented(let isPresented):
                state.isTransactionPickerPresented = isPresented
                return nil
            }
        }

        // MARK: - Effects

        private var lookUpIpify: Effect<Action> {
            .task(id: EffectID.ipify) { [dependencies] in .ipifyResolved(await dependencies.ipifyAddress()) }
        }

        /// The `where` matters: a signal yielded just after `onDisappear` can already be buffered when
        /// the cancelled iterator first runs, and `AsyncStream` delivers buffered elements before it
        /// finishes. Skipping them makes disappearing a hard stop.
        private var polling: Effect<Action> {
            .stream(id: EffectID.polling) { [dependencies] send in
                for await _ in dependencies.pollTicks() where !Task.isCancelled {
                    send(.pollTick)
                }
            }
        }

        /// Event-driven rather than polled: the list only changes when the tunnel builds a new batch, and
        /// asking for it costs an IPC round-trip. Seeds once, because a signal posted before the menu
        /// opened is gone — Darwin notifications are a prod, not a queue.
        private var observeConnectionConfigurations: Effect<Action> {
            .stream(id: EffectID.connectionConfigurations) { [dependencies] send in
                send(.connectionConfigurationsUpdated(await dependencies.connectionConfigurations()))
                for await _ in dependencies.connectionConfigurationChanges() where !Task.isCancelled {
                    send(.connectionConfigurationsUpdated(await dependencies.connectionConfigurations()))
                }
            }
        }
    }
}
