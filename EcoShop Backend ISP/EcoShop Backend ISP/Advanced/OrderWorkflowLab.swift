import SwiftUI

struct OrderWorkflowLab: View {
    @StateObject private var session = OrderLabSession()
    var body: some View {
        OrderLabScreen(history: session.history, entry: session.entry,
                       reader: session.historyPort, writer: session.submissionPort)
    }
}

private struct OrderLabScreen: View {
    @ObservedObject var history: OrderHistoryModel
    @ObservedObject var entry: OrderEntryModel
    let reader: HistoryPort
    let writer: SubmissionPort
    @State private var showEntry = false
    @State private var historyOffline = false
    @State private var entryOffline = false
    @State private var configuring = false
    @State private var showControls = false
    @State private var isVisible = false
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 38

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        LedgerStyle.label("ECOSHOP / TWO DESKS")
                        Spacer(minLength: 12)
                        LedgerStyle.label("LAB 04 / B")
                    }.fixedSize(horizontal: true, vertical: false)
                    VStack(alignment: .leading, spacing: 8) {
                        LedgerStyle.label("ECOSHOP / TWO DESKS")
                        LedgerStyle.label("LAB 04 / B")
                    }
                }
                LedgerStyle.divider
                Text("One book.\nTwo desks.").font(.system(size: titleSize, design: .serif))
                    .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                Text("Record a purchase. Read its history independently.")
                    .font(.subheadline).foregroundStyle(LedgerStyle.secondary)
                HStack {
                    Button("History") { showEntry = false; history.load() }
                        .accessibilityIdentifier("lab-history")
                    Spacer()
                    Button("Order entry") { showEntry = true; history.cancel() }
                        .accessibilityIdentifier("lab-entry")
                }.buttonStyle(.bordered).font(.system(.subheadline, design: .monospaced))
                Button("Connection controls") { showControls.toggle() }
                    .buttonStyle(.bordered).accessibilityIdentifier("lab-connections")
                    .accessibilityValue(showControls ? "Expanded" : "Collapsed")
                if showControls {
                    Button(historyOffline ? "Restore history" : "Take history offline") {
                        configuring = true
                        history.cancel()
                        Task {
                            historyOffline.toggle()
                            await reader.setOffline(historyOffline)
                            configuring = false
                            if isVisible && !showEntry { history.load() }
                        }
                    }.frame(minHeight: 44, alignment: .leading).disabled(configuring).accessibilityIdentifier("lab-history-fault")
                    Button(entryOffline ? "Restore entry" : "Take entry offline") {
                        configuring = true
                        Task {
                            entryOffline.toggle()
                            await writer.setOffline(entryOffline)
                            configuring = false
                        }
                    }.frame(minHeight: 44, alignment: .leading).disabled(configuring || entry.isSubmitting).accessibilityIdentifier("lab-entry-fault")
                }
                LedgerStyle.divider
                if showEntry { OrderEntryDesk(model: entry).disabled(configuring) }
                else { OrderHistoryDesk(model: history) }
                LedgerStyle.divider
                Text("A separate study book / local GBP records. No payment is taken.")
                    .font(.footnote).foregroundStyle(LedgerStyle.secondary)
                LedgerStyle.label("JB / SWIFT STUDIES     ·     CAPABILITY LAB")
            }
            .padding(20).frame(maxWidth: 660).frame(maxWidth: .infinity)
        }
        .clipped().background(LedgerStyle.paper).foregroundStyle(LedgerStyle.ink).tint(LedgerStyle.ink)
        .task {
            isVisible = true
            if !showEntry && !configuring { await history.load().value }
        }
        .onDisappear { isVisible = false; history.cancel(); entry.cancel() }
    }
}

/// A read-only consumer: its model exposes no submission operation.
private struct OrderHistoryDesk: View {
    @ObservedObject var model: OrderHistoryModel
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LedgerStyle.label("HISTORY / READ-ONLY DESK")
            Button("Refresh history") { model.load() }
                .buttonStyle(LedgerButtonStyle()).accessibilityIdentifier("lab-refresh")
            if model.isLoading { ProgressView("Opening the shared book…") }
            if let warning = model.warning {
                Text(warning).foregroundStyle(LedgerStyle.accent).accessibilityIdentifier("lab-history-warning")
            }
            if model.hasLoaded && model.records.isEmpty { Text("No orders recorded.") }
            ForEach(model.records) { receipt in
                VStack(alignment: .leading, spacing: 8) {
                    LedgerStyle.label("RECEIPT / \(receipt.id.uuidString.prefix(8))")
                    Text("Goods / \(receipt.draft.reference)").font(.system(.title3, design: .serif))
                    Text(receipt.amount, format: .currency(code: "GBP")).font(.system(.title2, design: .serif))
                    Text(receipt.recordedAt, format: .dateTime.hour().minute())
                        .font(.system(.caption, design: .monospaced)).foregroundStyle(LedgerStyle.secondary)
                }.padding(14).frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(Rectangle().stroke(LedgerStyle.rule))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("lab-record-\(receipt.id)")
            }
        }
    }
}

/// A submission-only consumer: saving does not reload history.
private struct OrderEntryDesk: View {
    @ObservedObject var model: OrderEntryModel
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LedgerStyle.label("ORDER ENTRY / SUBMISSION DESK")
            Text("Market tote / \(model.draft.reference)").font(.system(.title2, design: .serif))
            Text(Decimal(model.draft.totalPence) / 100, format: .currency(code: "GBP"))
                .font(.system(.largeTitle, design: .serif))
            Text("A prepared sample purchase. Each new draft records one order.")
                .font(.subheadline).foregroundStyle(LedgerStyle.secondary)
            if let receipt = model.receipt {
                LedgerStyle.label("RECEIPT CONFIRMED").accessibilityIdentifier("lab-receipt")
                LedgerStyle.label("REF / \(receipt.id.uuidString.prefix(8))")
                Button("Start another order") { model.newDraft() }
                    .buttonStyle(LedgerButtonStyle()).accessibilityIdentifier("lab-new-draft")
            } else {
                Button(model.isSubmitting ? "Recording…" : "Record this order") { model.submit() }
                    .buttonStyle(LedgerButtonStyle()).disabled(model.isSubmitting)
                    .accessibilityIdentifier("lab-submit")
            }
            if let message = model.message {
                Text(message).foregroundStyle(LedgerStyle.accent).accessibilityIdentifier("lab-entry-warning")
            }
        }
    }
}
