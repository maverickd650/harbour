# Harbour

A personal home lab dashboard for iPhone. Dark, minimal, glanceable — built for a TrueNAS + Unifi + Home Assistant + Plex + GitHub stack.

Drop in a URL, it detects the service, asks for credentials, and surfaces what matters: health, alerts, and activity across your cluster.

## Status

Early scaffold — designed in conversation with Claude, ready for implementation in Claude Code.

## Architecture

```
Harbour/
├── App/
│   └── HarbourApp.swift          # Entry point, SwiftData container setup
├── Models/
│   ├── ServiceDefinition.swift   # Core service model (persisted)
│   ├── ServiceType.swift         # Enum: truenas | unifi | homeAssistant | plex | github
│   ├── HealthStatus.swift        # ok | warning | error + message
│   └── AlertItem.swift           # Unified alert model across all services
├── Services/
│   ├── ServiceRegistry.swift     # Add/remove/reorder services (SwiftData)
│   ├── KeychainManager.swift     # Token storage — nothing sensitive in UserDefaults
│   ├── ServiceDetector.swift     # Auto-detects type from URL via parallel probes
│   ├── PollingEngine.swift       # Background refresh, configurable interval
│   └── API/
│       ├── TrueNASClient.swift
│       ├── UnifiClient.swift
│       ├── HomeAssistantClient.swift
│       ├── PlexClient.swift
│       └── GitHubClient.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift   # Root tab: health strip + alert banner + service cards
│   │   ├── HealthStripView.swift # Compact per-service status dots
│   │   ├── ServiceCardView.swift # Expandable card with key metrics
│   │   └── MiniWidgetRow.swift   # WAN / now playing / commits row
│   ├── AddService/
│   │   ├── AddServiceSheet.swift # Bottom sheet: URL tab + Browse tab
│   │   ├── DetectionView.swift   # Animated probe sequence
│   │   └── CredentialFormView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── ServiceListView.swift # Reorder, enable/disable, delete
└── Utilities/
    ├── Extensions.swift
    └── Constants.swift

HarbourWidget/
└── HarbourWidget.swift           # iOS 17 WidgetKit — small (health strip) + medium (top alert)
```

## Supported services

| Service | Auth | Key data |
|---|---|---|
| TrueNAS SCALE | API key (`Authorization: Bearer`) | Pool health, disk temps, SMART, alerts |
| Unifi | Session cookie (login → reuse) | Clients, WAN, AP status, throughput |
| Home Assistant | Long-lived token | Entity states, last automation |
| Plex | `X-Plex-Token` param | Active streams, library count, transcodes |
| GitHub / Gitea | Personal access token | Commits, open PRs, issues |

## Adding a service

1. Tap `+` on the dashboard
2. Paste any local IP or hostname — the app probes known API paths in parallel
3. First match wins; you're shown what it detected and what capabilities are available
4. Enter credentials — stored in Keychain, never on disk
5. Service appears on the dashboard within one polling cycle

## Design

- Dark, minimal — `#0a0a0a` base, SF Pro, no gradients
- Health-first: alerts surface immediately, green means genuinely green
- Extensible: `ServiceType` is an enum; adding a new service = new case + new `APIClient`
- Credentials: all tokens via Keychain (`kSecClassGenericPassword`), keyed by service UUID
- Persistence: SwiftData for service config, Keychain for secrets

## iOS target

iOS 17+ (SwiftData, WidgetKit interactive widgets)

## Getting started

The Xcode project is generated from [`project.yml`](project.yml) via [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `Harbour.xcodeproj` and `Harbour/Generated/Info.plist` are gitignored, not committed.

```bash
git clone https://github.com/YOU/harbour
cd harbour
brew install xcodegen
xcodegen generate
open Harbour.xcodeproj
```

Re-run `xcodegen generate` any time you add/remove source files or change `project.yml`.

## Getting started with Claude Code

```bash
claude
```

Suggested next Claude Code prompts:
- `implement UnifiClient.swift — self-signed TLS, session cookie auth, client/health/alarm endpoints`
- `implement HomeAssistantClient.swift and PlexClient.swift`
- `build HarbourWidget — small (health strip) + medium (top alert + 2 metrics) WidgetKit extension`
