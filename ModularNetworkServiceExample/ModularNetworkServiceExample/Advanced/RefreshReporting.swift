import OSLog

/// Lifecycle events deliberately contain no payload, URL, or raw error text.
enum RefreshEvent: String {
    case started, cacheShown, succeeded, failed, cancelled, superseded
}

@MainActor
protocol RefreshReporting {
    func record(_ event: RefreshEvent)
}

struct SystemRefreshReporter: RefreshReporting {
    private let logger = Logger(subsystem: "SOLID.NetworkStudy", category: "Refresh")
    func record(_ event: RefreshEvent) {
        logger.info("Refresh lifecycle: \(event.rawValue, privacy: .public)")
    }
}
