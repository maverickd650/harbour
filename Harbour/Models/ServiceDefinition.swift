import Foundation
import SwiftData

/// Persisted service config. Credentials never live here — see `KeychainManager`,
/// keyed by `id.uuidString`.
@Model
final class ServiceDefinition {
    var id: UUID
    var type: ServiceType
    var displayName: String
    var baseURL: URL
    var isEnabled: Bool
    var sortOrder: Int
    var lastPolled: Date?
    var lastStatus: HealthStatus

    init(
        id: UUID = UUID(),
        type: ServiceType,
        displayName: String,
        baseURL: URL,
        isEnabled: Bool = true,
        sortOrder: Int = 0,
        lastPolled: Date? = nil,
        lastStatus: HealthStatus = .unknown
    ) {
        self.id = id
        self.type = type
        self.displayName = displayName
        self.baseURL = baseURL
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
        self.lastPolled = lastPolled
        self.lastStatus = lastStatus
    }
}
