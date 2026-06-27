import Foundation

enum AlertSeverity: String, Codable, Comparable {
    case info, warning, critical

    private var rank: Int {
        switch self {
        case .info: return 0
        case .warning: return 1
        case .critical: return 2
        }
    }

    static func < (lhs: AlertSeverity, rhs: AlertSeverity) -> Bool {
        lhs.rank < rhs.rank
    }
}

struct AlertItem: Identifiable, Codable, Equatable {
    var id: UUID
    var serviceID: UUID
    var severity: AlertSeverity
    var message: String
    var timestamp: Date

    init(id: UUID = UUID(), serviceID: UUID, severity: AlertSeverity, message: String, timestamp: Date = .now) {
        self.id = id
        self.serviceID = serviceID
        self.severity = severity
        self.message = message
        self.timestamp = timestamp
    }
}
