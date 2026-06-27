# Handover — Harbour iOS App

Everything Claude Code needs to pick this up and run.

## What this is

A personal iPhone app: a home lab dashboard. Think Homepage (the self-hosted web dashboard) but native iOS, health-first, and extensible by URL. The owner runs TrueNAS, Unifi (home cluster), Home Assistant, Plex, and GitHub/GitLab.

## Design decisions already made

- **Dark minimal aesthetic** — `#0a0a0a` background, SF Pro Display, no gradients, no blur
- **Health strip** — compact coloured dots at the top, one per service, always visible
- **Alert banner** — surfaces the highest-severity active alert inline on the dashboard
- **Expandable service cards** — tap to reveal key metrics per service
- **Mini widget row** — WAN speed / active Plex stream / commit count at a glance
- **URL-first onboarding** — paste a URL, app auto-detects service type via parallel API probes
- **Keychain-only credentials** — no secrets in UserDefaults or SwiftData ever
- **SwiftData for config** — service list, display names, URLs, ordering
- **WidgetKit** — small widget (health strip), medium widget (top alert + 2 metrics)

## UI already designed (mockups exist)

1. **Dashboard** — health strip → alert banner → mini widget row → service cards → tab bar
2. **Add Service sheet** — URL tab with live detection animation, Browse tab with service type picker
3. Both screens designed dark, real mock data matching the actual services

## Service detection logic

```
user pastes URL
→ fire parallel URLSession requests to each service's probe path
→ first 200 response that matches fingerprint wins
→ show "Detected: TrueNAS SCALE v24.04.1" card
→ ask for credential (type depends on service)
→ save to Keychain keyed by UUID
→ persist ServiceDefinition to SwiftData
```

Probe paths:
- TrueNAS:        GET /api/v2.0/system/info  → json has "version" + "hostname"
- Unifi:          GET /proxy/network/api/self → json has "meta"
- Home Assistant: GET /api/                  → json["message"] == "API running."
- Plex:           GET /identity              → json has "MediaContainer"
- GitHub:         GET /api/v3               → json has "current_user_url"

## API auth per service

| Service | Method | Header / Param |
|---|---|---|
| TrueNAS | API key | `Authorization: Bearer {key}` |
| Unifi | Session cookie | POST login → store `TOKEN` cookie |
| Home Assistant | Long-lived token | `Authorization: Bearer {token}` |
| Plex | Token param | `?X-Plex-Token={token}` |
| GitHub / Gitea | PAT | `Authorization: Bearer {pat}` |

## Data models (not yet implemented)

```swift
@Model class ServiceDefinition {
    var id: UUID
    var type: ServiceType
    var displayName: String
    var baseURL: URL
    var isEnabled: Bool
    var sortOrder: Int
    var lastPolled: Date?
    var lastStatus: HealthStatus
    // credentials in Keychain keyed by id.uuidString — NOT stored here
}

enum ServiceType: String, Codable, CaseIterable {
    case truenas, unifi, homeAssistant, plex, github
}

enum HealthStatus: Codable {
    case ok
    case warning(message: String)
    case error(message: String)
    case unknown
}

struct AlertItem: Identifiable {
    var id: UUID
    var serviceID: UUID
    var severity: AlertSeverity   // .info | .warning | .critical
    var message: String
    var timestamp: Date
}
```

## Suggested build order

1. `ServiceDefinition` model + SwiftData container in `HarbourApp.swift`
2. `KeychainManager` — save/load/delete by UUID key
3. `TrueNASClient` — pool health + alerts (cleanest API, start here)
4. `DashboardView` with one real TrueNAS service
5. `ServiceDetector` + `AddServiceSheet` — URL probe + credential form
6. `PollingEngine` — background refresh via `Task` + `.refreshable`
7. Remaining API clients (Unifi most complex — do last)
8. `HarbourWidget` — WidgetKit small + medium

## Hard rules

- Never store credentials in SwiftData or UserDefaults — Keychain only
- Don't use `URLSession.shared` directly — wrap per service client with auth injection
- Unifi uses self-signed TLS — handle `URLSessionDelegate` cert challenge, don't disable globally
- Everything dark: background `#0a0a0a`, cards `#111`, borders `#222`

## Tone

This is for one person. Infrastructure software register — tight, dense, no consumer fluff. Linear / Vercel dashboard energy, not App Store screenshot energy.
