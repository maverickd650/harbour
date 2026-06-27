import Foundation

enum HealthStatus: Codable, Equatable {
    case ok
    case warning(message: String)
    case error(message: String)
    case unknown

    private enum Kind: String, Codable {
        case ok, warning, error, unknown
    }

    private enum CodingKeys: String, CodingKey {
        case kind, message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .ok:
            self = .ok
        case .warning:
            self = .warning(message: try container.decode(String.self, forKey: .message))
        case .error:
            self = .error(message: try container.decode(String.self, forKey: .message))
        case .unknown:
            self = .unknown
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .ok:
            try container.encode(Kind.ok, forKey: .kind)
        case .warning(let message):
            try container.encode(Kind.warning, forKey: .kind)
            try container.encode(message, forKey: .message)
        case .error(let message):
            try container.encode(Kind.error, forKey: .kind)
            try container.encode(message, forKey: .message)
        case .unknown:
            try container.encode(Kind.unknown, forKey: .kind)
        }
    }

    var message: String? {
        switch self {
        case .ok, .unknown: return nil
        case .warning(let message), .error(let message): return message
        }
    }

    /// Dot color in the health strip — `#0a0a0a` background, never gradients.
    var dotColorHex: String {
        switch self {
        case .ok: return "2ECC71"
        case .warning: return "F5A623"
        case .error: return "E5484D"
        case .unknown: return "555555"
        }
    }
}
