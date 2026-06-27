# API Reference

Quick reference for all five service APIs.

## TrueNAS SCALE

Base: `http://{host}/api/v2.0`  
Auth: `Authorization: Bearer {api_key}`

```
GET /system/info     → hostname, version, uptime
GET /pool            → pools: name, status, size, allocated
GET /disk            → disks: name, temp, serial
GET /alert/list      → active alerts: level, message, datetime
GET /pool/dataset    → datasets and snapshots
```

Generate: TrueNAS UI → Credentials → API Keys → Add

## Unifi

Base: `https://{udm-host}` (self-signed cert — custom URLSessionDelegate required)

```
POST /api/auth/login                                  body: {username, password}
GET  /proxy/network/api/s/default/stat/sta            → connected clients
GET  /proxy/network/api/s/default/stat/health         → WAN, WLAN, WWW health
GET  /proxy/network/api/s/default/stat/device         → APs and switches
GET  /proxy/network/api/s/default/rest/alarm          → active alarms
```

Re-auth on 401. Store session cookie in `HTTPCookieStorage`.

## Home Assistant

Base: `http://{host}:8123`  
Auth: `Authorization: Bearer {long_lived_token}`

```
GET /api/            → probe: {"message": "API running."}
GET /api/states      → all entity states
GET /api/events      → recent events
```

Generate: HA → Profile → Long-Lived Access Tokens → Create

## Plex

Base: `http://{host}:32400`  
Auth: `?X-Plex-Token={token}` on every request

```
GET /identity              → probe: server name + version
GET /status/sessions       → active streams: user, media, progress
GET /library/sections      → libraries
```

## GitHub

Base: `https://api.github.com`  
Auth: `Authorization: Bearer {pat}`  
Scopes needed: `repo`, `read:user`

```
GET /user/repos                          → repos (?sort=pushed for recent)
GET /user/events                         → activity feed
GET /repos/{owner}/{repo}/commits        → commit history
GET /repos/{owner}/{repo}/pulls          → open PRs
GET /issues?filter=assigned              → assigned issues
```

**Gitea**: identical shape — change base URL to `http://{host}/api/v1`.
