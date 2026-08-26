//
//  PromoOffersPoCView.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  Proof-of-concept only: a plain SwiftUI screen to exercise the Apple promotional (win-back)
//  offer flow. Intentionally does not follow the project's UI/architecture conventions.
//

import PIALibrary
import SwiftUI

struct PromoOffersPoCView: View {

    private let service = PromoOffersService()

    @State private var country = Locale.current.regionCode ?? ""
    @State private var appAccountToken = UUID()

    @State private var rows: [PromoOffersService.ProductRow] = []
    @State private var note: String?
    @State private var loadError: String?
    @State private var isLoading = false
    @State private var isBusy = false
    @State private var log = "Ready.\n"

    var body: some View {
        Form {
            inputsSection
            productsSection
            logSection
        }
//            .navigationTitle("Promo Offers PoC")
//            .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    // MARK: Sections

    private var inputsSection: some View {
        Section("Input") {
            HStack {
                Text("Country")
                TextField("US", text: $country)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.trailing)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("app_account_token").font(.caption).foregroundStyle(.secondary)
                Text(appAccountToken.uuidString).font(.footnote.monospaced())
                Button("Regenerate token") { appAccountToken = UUID() }
                    .font(.caption)
            }
        }
    }

    private var productsSection: some View {
        Section {
            if isLoading {
                HStack { ProgressView(); Text("Loading products & offers…") }
            } else if let loadError {
                Text(loadError).foregroundStyle(.red)
            } else {
                ForEach(rows) { row in
                    productRow(row)
                }
            }
        } header: {
            HStack {
                Text("Products & eligible offers")
                Spacer()
                Button("Reload") { Task { await load() } }
                    .font(.caption)
                    .disabled(isLoading)
            }
        } footer: {
            if let note {
                Text(note)
            }
        }
    }

    @ViewBuilder
    private func productRow(_ row: PromoOffersService.ProductRow) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(row.displayName ?? row.label)
                .font(.subheadline.bold())
                .foregroundStyle(row.available ? .primary : .secondary)
            Text(row.id)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            if let price = row.displayPrice {
                Text("Base price: \(price)").font(.caption).foregroundStyle(.secondary)
            }

            if !row.available {
                Text("Unavailable in the App Store.")
                    .font(.caption).foregroundStyle(.secondary)
            } else if row.eligibleOffers.isEmpty {
                Text("No eligible offers.")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                ForEach(row.eligibleOffers, id: \.offer.id) { (offer, eligible) in
                    Button {
                        Task { await signAndPurchase(productIdentifier: row.id, offer: offer) }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(offer.id).font(.footnote)
                                Text(offer.displayPrice)
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                    }
                    .disabled(!eligible || isBusy)
                }
            }
        }
        .padding(.vertical, 4)
        // Products with no actionable offers read as disabled.
        .opacity(row.available && !row.eligibleOffers.isEmpty ? 1 : 0.55)
    }

    private var logSection: some View {
        Section("Log") {
            ScrollView {
                Text(log)
                    .font(.footnote.monospaced())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(minHeight: 160)
            Button("Clear log") { log = "" }.font(.caption)
        }
    }

    // MARK: Actions

    private func load() async {
        isLoading = true
        loadError = nil
        note = nil
        rows = []
        append("→ Loading products & eligible offers (country: \(countryOrNil ?? "nil"))…")
        do {
            let catalog = try await service.loadCatalog(country: countryOrNil)
            if let jws = catalog.receiptJWS {
                append("receipt JWS: \(jws.prefix(24))… (\(jws.count) chars)")
            }
            append("offer_identifiers: \(catalog.offerIdentifiers)")
            if let note = catalog.note { append("note: \(note)") }
            for row in catalog.rows {
                let ids = row.eligibleOffers.map(\.offer.id)
                append("\(row.label) [\(row.available ? "available" : "unavailable")] eligible offers: \(ids)")
            }
            rows = catalog.rows
            note = catalog.note
        } catch {
            loadError = error.localizedDescription
            append("✗ \(error.localizedDescription)")
        }
        isLoading = false
    }

    private func signAndPurchase(productIdentifier: String, offer: InAppPromotionalOffer) async {
        isBusy = true
        append("→ Signing + purchasing \(offer.id) on \(productIdentifier)…")
        do {
            let summary = try await service.signAndPurchase(
                productIdentifier: productIdentifier,
                offerIdentifier: offer.id,
                appAccountToken: appAccountToken,
                country: countryOrNil
            )
            append(summary)
        } catch {
            append("✗ \(error.localizedDescription)")
        }
        isBusy = false
    }

    // MARK: Helpers

    private var countryOrNil: String? {
        let trimmed = country.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func append(_ line: String) {
        log += line + "\n"
    }
}
