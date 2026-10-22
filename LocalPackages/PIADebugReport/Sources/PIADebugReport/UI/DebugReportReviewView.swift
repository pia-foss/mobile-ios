//
//  DebugReportReviewView.swift
//  PIADebugReport
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

#if os(iOS)
    import PIADesignSystem
    import PIALibrary
    import PIALocalizations
    import PIASwiftUI
    import SwiftUI
    import UIKit

    public struct DebugReportReviewView: View, ViewWithTitle {
        fileprivate enum Metrics {
            /// Keeps the cards readable on iPad and Mac Catalyst instead of stretching edge to edge.
            static let maxContentWidth: CGFloat = 600
            static let separatorHeight: CGFloat = 1
            static let previewRadius: CGFloat = 8
        }

        @ObservedObject private var store: DebugReportReviewStore
        @State private var isSharing = false

        public init(store: DebugReportReviewStore) {
            self.store = store
        }

        public var navigationTitle: String { L10n.DebugReportReview.title }

        public var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: PIASpacing.s24) {
                    Text(L10n.DebugReportReview.privacy)
                        .typography(.body2, color: .pia.onSurfaceContainerPrimary)
                        .padding(.horizontal, PIASpacing.s4)

                    DebugReportContents(state: store.state)
                }
                .padding(PIASpacing.s16)
                .frame(maxWidth: Metrics.maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .background(Color.pia.background.ignoresSafeArea())
            // Pinned so Send stays reachable however far an expanded log pushes the content.
            .safeAreaInset(edge: .bottom) {
                DebugReportActions(
                    state: store.state,
                    send: { store.send(.sendTapped) },
                    share: { isSharing = true }
                )
            }
            .sheet(isPresented: $isSharing) {
                ActivityView(items: [store.state.reportText])
            }
            .onAppear { store.send(.onAppear) }
        }
    }

    // MARK: - Contents

    /// "What will be sent": every section in the report, in the order it is submitted.
    private struct DebugReportContents: View {
        let state: DebugReportReview.State

        var body: some View {
            VStack(alignment: .leading, spacing: PIASpacing.s8) {
                Text(L10n.DebugReportReview.Sections.title)
                    .typography(.subtitle2, color: .pia.onSurface)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, PIASpacing.s4)

                content

                Footnote(text: L10n.DebugReportReview.redacted, systemImage: "lock.fill")
            }
        }

        @ViewBuilder
        private var content: some View {
            if !state.hasBuilt {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PIASpacing.s40)
                    .debugReportCard()
            } else if state.sections.isEmpty {
                Text(L10n.DebugReportReview.Sections.empty)
                    .typography(.body2, color: .pia.onSurfaceContainerPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(PIASpacing.s16)
                    .debugReportCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(state.sections) { section in
                        if section.id != state.sections.first?.id {
                            CardSeparator()
                        }
                        DebugReportSectionRow(section: section)
                    }
                }
                .debugReportCard()
            }
        }
    }

    /// One CSI section, with its content revealed on demand. The content is capped so a large log
    /// does not stall the screen; "Save report" still shares the full text.
    private struct DebugReportSectionRow: View {
        let section: DebugReport.Section

        @State private var isExpanded = false

        private static let previewCharacterLimit = 4_000

        var body: some View {
            VStack(alignment: .leading, spacing: PIASpacing.s12) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        isExpanded.toggle()
                    }
                } label: {
                    header
                }
                .buttonStyle(.plain)
                .accessibilityHint(L10n.DebugReportReview.Sections.expandHint)
                .accessibilityIdentifier("debugReportSection.\(section.id)")

                if isExpanded {
                    VStack(alignment: .leading, spacing: PIASpacing.s8) {
                        Text(preview)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.pia.onSurfaceContainerPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding(PIASpacing.s12)
                            .background(Color.pia.background)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: DebugReportReviewView.Metrics.previewRadius,
                                    style: .continuous
                                )
                            )

                        if isTruncated {
                            Text(L10n.DebugReportReview.Sections.truncated)
                                .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, PIASpacing.s16)
            .padding(.vertical, PIASpacing.s12)
        }

        private var header: some View {
            HStack(spacing: PIASpacing.s12) {
                Image(systemName: section.symbolName)
                    .font(.body)
                    .foregroundColor(.pia.primary)
                    .frame(width: PIASpacing.s24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(section.displayName)
                        .typography(.body1, color: .pia.onSurface)
                    // The CSI name is what support sees, so it stays visible next to the friendly one.
                    Text("\(section.name) · \(size)")
                        .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.pia.onSurfaceContainerSecondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }

        private var size: String {
            Self.sizeFormatter.string(fromByteCount: Int64(section.content.utf8.count))
        }

        /// Spells out "0 bytes" rather than the formatter's default "Zero KB" for empty sections.
        private static let sizeFormatter: ByteCountFormatter = {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            formatter.allowsNonnumericFormatting = false
            return formatter
        }()

        private var isTruncated: Bool {
            section.content.count > Self.previewCharacterLimit
        }

        private var preview: String {
            guard isTruncated else { return section.content }
            return String(section.content.prefix(Self.previewCharacterLimit)) + "\n…"
        }
    }

    // MARK: - Actions

    private struct DebugReportActions: View {
        let state: DebugReportReview.State
        let send: () -> Void
        let share: () -> Void

        var body: some View {
            VStack(spacing: PIASpacing.s4) {
                Button(action: send) {
                    Text(L10n.DebugReportReview.send).typography(.button1)
                }
                .buttonStyle(PIAButtonStyle(.primary, isLoading: state.isSending))
                // While sending the style shows its spinner and stops taps itself; disabling it too
                // would dim the fill and bury the spinner.
                .disabled(!state.canSend && !state.isSending)
                .accessibilityIdentifier("debugReportSendButton")

                Button(action: share) {
                    HStack(spacing: PIASpacing.s8) {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityHidden(true)
                        Text(L10n.DebugReportReview.share).typography(.button1)
                    }
                }
                .buttonStyle(PIAButtonStyle(.plain))
                .disabled(!state.canSend)
                .accessibilityIdentifier("debugReportShareButton")
            }
            .padding(.horizontal, PIASpacing.s16)
            .padding(.top, PIASpacing.s12)
            .frame(maxWidth: DebugReportReviewView.Metrics.maxContentWidth)
            .frame(maxWidth: .infinity)
            .background(
                Color.pia.background
                    .overlay(alignment: .top) { CardSeparator() }
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: - Building blocks

    private struct Footnote: View {
        let text: String
        let systemImage: String

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: PIASpacing.s4) {
                Image(systemName: systemImage)
                    .font(.caption)
                    .accessibilityHidden(true)
                Text(text).typography(.caption1)
            }
            .foregroundColor(.pia.onSurfaceContainerSecondary)
            .padding(.horizontal, PIASpacing.s4)
        }
    }

    private struct CardSeparator: View {
        var body: some View {
            Color.pia.outline
                .frame(height: DebugReportReviewView.Metrics.separatorHeight)
        }
    }

    extension View {
        fileprivate func debugReportCard() -> some View {
            frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.pia.surfaceContainerPrimary)
                .clipShape(RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous))
        }
    }

    extension DebugReport.Section {
        /// A user-facing name for the CSI section, falling back to the raw name for any section
        /// added to `DebugReportBuilder` without one.
        fileprivate var displayName: String {
            switch name {
            case "protocol_information": return L10n.DebugReportReview.Section.protocolInformation
            case "device_information": return L10n.DebugReportReview.Section.deviceInformation
            case "application.log": return L10n.DebugReportReview.Section.applicationLog
            case "subscription_information": return L10n.DebugReportReview.Section.subscriptionInformation
            case "regions.json": return L10n.DebugReportReview.Section.regions
            case "user_settings": return L10n.DebugReportReview.Section.userSettings
            case "last_known_exception": return L10n.DebugReportReview.Section.lastKnownException
            case "tunnel.log": return L10n.DebugReportReview.Section.tunnelLog
            case "last_tunnel.log": return L10n.DebugReportReview.Section.lastTunnelLog
            case "vpn_status": return L10n.DebugReportReview.Section.vpnStatus
            default: return name
            }
        }

        /// Symbols are limited to SF Symbols 3 so they render on the iOS 15 deployment target.
        fileprivate var symbolName: String {
            switch name {
            case "protocol_information": return "lock.shield"
            case "device_information": return "iphone"
            case "subscription_information": return "creditcard"
            case "regions.json": return "globe"
            case "user_settings": return "gearshape"
            case "last_known_exception": return "exclamationmark.triangle"
            case "vpn_status": return "bolt.horizontal"
            default:
                switch kind {
                case .debugLog: return "doc.text"
                case .tunnelLog: return "list.bullet.rectangle"
                case .mandatory: return "info.circle"
                }
            }
        }
    }

    /// Presents the system share sheet for the exact report text. `ShareLink` is iOS 16+, so the
    /// iOS 15 deployment target needs the UIKit bridge.
    private struct ActivityView: UIViewControllerRepresentable {
        let items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: items, applicationActivities: nil)
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
#endif
