import Foundation

enum ServiceType: String, Codable, CaseIterable, Identifiable, Hashable {
    case truenas
    case unifi
    case homeAssistant
    case plex
    case github

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .truenas: return "TrueNAS"
        case .unifi: return "Unifi"
        case .homeAssistant: return "Home Assistant"
        case .plex: return "Plex"
        case .github: return "GitHub"
        }
    }

    var systemImageName: String {
        switch self {
        case .truenas: return "internaldrive"
        case .unifi: return "wifi.router"
        case .homeAssistant: return "house"
        case .plex: return "play.tv"
        case .github: return "chevron.left.forwardslash.chevron.right"
        }
    }

    /// Path probed against a candidate base URL during URL-first onboarding.
    var probePath: String {
        switch self {
        case .truenas: return "/api/v2.0/system/info"
        case .unifi: return "/proxy/network/api/self"
        case .homeAssistant: return "/api/"
        case .plex: return "/identity"
        case .github: return "/api/v3"
        }
    }

    /// Returns true if the decoded JSON probe response matches this service's fingerprint.
    func matchesFingerprint(_ json: [String: Any]) -> Bool {
        switch self {
        case .truenas:
            return json["version"] != nil && json["hostname"] != nil
        case .unifi:
            return json["meta"] != nil
        case .homeAssistant:
            return (json["message"] as? String) == "API running."
        case .plex:
            return json["MediaContainer"] != nil
        case .github:
            return json["current_user_url"] != nil
        }
    }

    /// Short detail string for the detection card, e.g. "v24.04.1".
    func detailLine(from json: [String: Any]) -> String? {
        switch self {
        case .truenas:
            return (json["version"] as? String)
        case .plex:
            guard let container = json["MediaContainer"] as? [String: Any] else { return nil }
            return (container["version"] as? String).map { "v\($0)" }
        case .homeAssistant, .unifi, .github:
            return nil
        }
    }

    enum CredentialKind {
        case apiKey
        case usernamePassword
        case longLivedToken
        case token
        case personalAccessToken
    }

    var credentialKind: CredentialKind {
        switch self {
        case .truenas: return .apiKey
        case .unifi: return .usernamePassword
        case .homeAssistant: return .longLivedToken
        case .plex: return .token
        case .github: return .personalAccessToken
        }
    }
}
