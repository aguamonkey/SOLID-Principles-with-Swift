import SwiftUI

struct RefreshLabView: View {
    @StateObject private var session = RefreshLabSession()

    var body: some View {
        RefreshLabScreen(model: session.model, transport: session.transport)
    }
}

private struct RefreshLabScreen: View {
    @ObservedObject var model: RefreshViewModel
    let transport: DemoRefreshTransport
    @State private var configuring = false
    @State private var configurationTask: Task<Void, Never>?
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 34

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    PatchboardStyle.label("NETWORK SERVICE")
                    Spacer()
                    PatchboardStyle.label("LAB 05 / B")
                }
                Text("KEEP / REFRESH.")
                    .font(.system(size: headingSize, weight: .black))
                    .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                Text("Read the saved signal. Refresh when you’re ready.")
                    .font(.subheadline).foregroundStyle(PatchboardStyle.secondary)
                Rectangle().fill(PatchboardStyle.ink).frame(height: 3).accessibilityHidden(true)
                PatchboardStyle.label(status).accessibilityIdentifier("refresh-status")
                if model.phase == .refreshing {
                    ProgressView("Receiving an update…")
                }
                VStack(alignment: .leading, spacing: 16) {
                    PatchboardStyle.label(model.snapshot == nil ? "NO SAVED SIGNAL" : model.isCached ? "SAVED SIGNAL" : "LATEST SIGNAL")
                    Text(payload).font(.system(.body, design: .monospaced))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("refresh-payload")
                    if let snapshot = model.snapshot {
                        Text("Received \(snapshot.receivedAt.formatted(date: .omitted, time: .standard))")
                            .font(.caption).foregroundStyle(PatchboardStyle.signal)
                    }
                }
                .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                .background(PatchboardStyle.terminal).foregroundStyle(PatchboardStyle.signal)
                if let warning = model.warning {
                    Text(warning).font(.subheadline).foregroundStyle(PatchboardStyle.accent)
                        .accessibilityIdentifier("refresh-warning")
                }
                if model.phase == .refreshing {
                    Button("Cancel refresh") { model.cancelRefresh() }
                        .buttonStyle(PatchButtonStyle()).accessibilityIdentifier("refresh-cancel")
                }
                Button(model.phase == .refreshing ? "Refresh again" : "Refresh signal") { start(.updated) }
                    .buttonStyle(PatchButtonStyle()).disabled(configuring)
                    .accessibilityIdentifier("refresh-updated")
                Button("Try an offline refresh") { start(.offline) }
                    .buttonStyle(PatchButtonStyle()).disabled(configuring)
                    .accessibilityIdentifier("refresh-offline")
                Text("All inputs are local. Offline refresh keeps the saved signal; reopening this lab reads the latest saved edition.")
                    .font(.footnote).foregroundStyle(PatchboardStyle.secondary)
                Rectangle().fill(PatchboardStyle.rule).frame(height: 1).accessibilityHidden(true)
                PatchboardStyle.label("JB / SWIFT STUDIES     ·     REFRESH LAB")
            }
            .padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }
        .background(PatchboardStyle.paper).foregroundStyle(PatchboardStyle.ink)
        .task {
            // Opening reads the cache and revalidates through the same contract.
            await model.refresh().value
        }
        .onDisappear {
            configurationTask?.cancel()
            configuring = false
            model.cancelRefresh()
        }
    }

    private var payload: String {
        guard let data = model.snapshot?.data else { return "No saved signal yet." }
        return String(data: data, encoding: .utf8) ?? "Binary signal / \(data.count) bytes"
    }

    private var status: String {
        switch model.phase {
        case .idle: return "STANDBY"
        case .refreshing: return model.snapshot == nil ? "REFRESHING / FIRST SIGNAL" : "REFRESHING / SAVED CONTENT STAYS"
        case .ready: return "UPDATED / SIGNAL SAVED"
        case .failed: return model.snapshot == nil ? "OFFLINE / NO SAVED SIGNAL" : "OFFLINE / SAVED CONTENT KEPT"
        case .cancelled: return model.snapshot == nil ? "CANCELLED / NO SAVED SIGNAL" : "CANCELLED / SAVED CONTENT KEPT"
        case .superseded: return "SUPERSEDED / REFRESH AGAIN"
        }
    }

    private func start(_ input: DemoRefreshTransport.Input) {
        // Finish adapter configuration before issuing the next request.
        configuring = true
        model.cancelRefresh()
        configurationTask?.cancel()
        configurationTask = Task {
            do {
                try await transport.select(input)
                try Task.checkCancellation()
                configuring = false
                model.refresh()
            } catch {
                if !Task.isCancelled { configuring = false }
            }
        }
    }
}
