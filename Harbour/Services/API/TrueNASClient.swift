import Foundation

struct TrueNASSystemInfo: Decodable {
    let hostname: String
    let version: String
    let uptimeSeconds: Double?

    private enum CodingKeys: String, CodingKey {
        case hostname, version
        case uptimeSeconds = "uptime_seconds"
    }
}

struct TrueNASPool: Decodable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let size: Int64?
    let allocated: Int64?
}

struct TrueNASDisk: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let temp: Int?
    let serial: String?
}

private struct TrueNASAlert: Decodable {
    let level: String
    let formatted: String?
    let text: String?
    let datetime: TrueNASDateTime?

    var message: String { formatted ?? text ?? "Alert" }
}

private struct TrueNASDateTime: Decodable {
    let date: Date?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let epoch = try container.decodeIfPresent(Double.self, forKey: .epoch) {
            date = Date(timeIntervalSince1970: epoch)
        } else {
            date = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case epoch = "$date"
    }
}

/// Cleanest of the five APIs — pool health, disk temps, and alerts via a single bearer token.
final class TrueNASClient: APIClient {
    private let apiKey: String

    init(baseURL: URL, apiKey: String) {
        self.apiKey = apiKey
        super.init(baseURL: baseURL.appendingPathComponent("api/v2.0"))
    }

    override func authorize(_ request: inout URLRequest) {
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }

    func fetchSystemInfo() async throws -> TrueNASSystemInfo {
        try await get("/system/info", as: TrueNASSystemInfo.self)
    }

    func fetchPools() async throws -> [TrueNASPool] {
        try await get("/pool", as: [TrueNASPool].self)
    }

    func fetchDisks() async throws -> [TrueNASDisk] {
        try await get("/disk", as: [TrueNASDisk].self)
    }

    func fetchAlerts(serviceID: UUID) async throws -> [AlertItem] {
        let alerts = try await get("/alert/list", as: [TrueNASAlert].self)
        return alerts.map {
            AlertItem(
                serviceID: serviceID,
                severity: $0.severity,
                message: $0.message,
                timestamp: $0.datetime?.date ?? .now
            )
        }
    }

    /// Combines pool status and active alerts into one `HealthStatus` for the health strip.
    func fetchHealth(serviceID: UUID) async throws -> HealthStatus {
        let pools = try await fetchPools()
        let alerts = try await fetchAlerts(serviceID: serviceID)

        if let critical = alerts.first(where: { $0.severity == .critical }) {
            return .error(message: critical.message)
        }
        if let degraded = pools.first(where: { $0.status.uppercased() != "ONLINE" }) {
            return .warning(message: "Pool \(degraded.name) is \(degraded.status)")
        }
        if let warning = alerts.first(where: { $0.severity == .warning }) {
            return .warning(message: warning.message)
        }
        return .ok
    }
}

private extension TrueNASAlert {
    var severity: AlertSeverity {
        switch level.uppercased() {
        case "CRITICAL", "ALERT", "EMERGENCY":
            return .critical
        case "WARNING", "NOTICE":
            return .warning
        default:
            return .info
        }
    }
}
