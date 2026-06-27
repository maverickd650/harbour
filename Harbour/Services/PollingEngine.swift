import Foundation
import Observation

/// Background refresh loop. Each enabled service is polled on `refreshInterval`
/// using its own API client with credentials pulled from the Keychain.
@Observable
final class PollingEngine {
    private let registry: ServiceRegistry
    private var loopTask: Task<Void, Never>?
    var refreshInterval: TimeInterval = 60
    var isPolling = false

    init(registry: ServiceRegistry) {
        self.registry = registry
    }

    func start() {
        stop()
        isPolling = true
        loopTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                await self.refreshAll()
                try? await Task.sleep(for: .seconds(self.refreshInterval))
            }
        }
    }

    func stop() {
        loopTask?.cancel()
        loopTask = nil
        isPolling = false
    }

    func refreshAll() async {
        await withTaskGroup(of: Void.self) { group in
            for service in registry.fetchAll() where service.isEnabled {
                group.addTask { await self.refresh(service) }
            }
        }
    }

    func refresh(_ service: ServiceDefinition) async {
        guard let credential = KeychainManager.load(for: service.id) else {
            registry.updateStatus(service, status: .error(message: "No credentials"))
            return
        }

        switch service.type {
        case .truenas:
            let client = TrueNASClient(baseURL: service.baseURL, apiKey: credential)
            do {
                let status = try await client.fetchHealth(serviceID: service.id)
                registry.updateStatus(service, status: status)
            } catch {
                registry.updateStatus(service, status: .error(message: "Unreachable"))
            }
        case .unifi, .homeAssistant, .plex, .github:
            // API clients for these land in a follow-up pass — see HANDOVER.md build order.
            break
        }
    }
}
