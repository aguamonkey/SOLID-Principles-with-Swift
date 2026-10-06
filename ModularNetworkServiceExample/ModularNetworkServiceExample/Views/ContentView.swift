import SwiftUI

/// A fixed receiver: only the repository and logger contracts enter this screen.
public struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel
    private let endpoint: URL

    public init(networkRepository: NetworkRepositoryProtocol, logger: LoggingServiceProtocol, endpoint: URL) {
        _viewModel = StateObject(wrappedValue: ContentViewModel(networkRepository: networkRepository, logger: logger))
        self.endpoint = endpoint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                PatchboardStyle.label("02 — RECEIVER / VIEW MODEL")
                Text(status).font(.system(.title2, design: .monospaced).bold())
                    .accessibilityIdentifier("receiver-status")
                Text(message).font(.system(.body, design: .monospaced))
                    .fixedSize(horizontal: false, vertical: true).textSelection(.enabled)
                    .accessibilityIdentifier("receiver-message")
                if viewModel.isLoading { ProgressView().tint(PatchboardStyle.signal) }
                if let data = viewModel.fetchedData {
                    PatchboardStyle.label("\(data.count) BYTES / UTF-8 PREVIEW")
                }
            }
            .padding(18).frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
            .background(PatchboardStyle.terminal).foregroundStyle(PatchboardStyle.signal)
            if viewModel.isLoading {
                Button("Cancel reception") { viewModel.cancelLoad() }
                    .buttonStyle(PatchButtonStyle()).accessibilityIdentifier("cancel-reception")
            } else {
                Button { viewModel.loadData(from: endpoint) } label: {
                    Label("Connect & receive", systemImage: "cable.connector")
                }.buttonStyle(PatchButtonStyle()).accessibilityIdentifier("receive")
            }
        }
        .onDisappear { viewModel.cancelLoad() }
    }

    private var status: String {
        if viewModel.isLoading { return "RECEIVING" }
        if viewModel.wasCancelled { return "CANCELLED" }
        if viewModel.errorMessage != nil { return "NO SIGNAL" }
        if viewModel.fetchedData != nil { return "RECEIVED" }
        return "STANDBY"
    }

    private var message: String {
        if viewModel.isLoading { return "Waiting for the selected input…" }
        if viewModel.wasCancelled { return "Reception stopped. Connect again when ready." }
        if let error = viewModel.errorMessage { return error }
        if let data = viewModel.fetchedData {
            if data.isEmpty { return "The input returned an empty payload." }
            return String(data: data.prefix(2_048), encoding: .utf8) ?? "Binary payload received. No UTF-8 preview available."
        }
        return "Input patched.\nConnect to receive a signal."
    }
}
