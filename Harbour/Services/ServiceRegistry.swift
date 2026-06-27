import Foundation
import SwiftData
import Observation

/// Add/remove/reorder services. Credentials never pass through here — callers
/// write to `KeychainManager` directly, keyed by the service's `id`.
@Observable
final class ServiceRegistry {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> [ServiceDefinition] {
        let descriptor = FetchDescriptor<ServiceDefinition>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func add(_ service: ServiceDefinition) {
        service.sortOrder = fetchAll().count
        modelContext.insert(service)
        save()
    }

    func remove(_ service: ServiceDefinition) {
        KeychainManager.delete(for: service.id)
        modelContext.delete(service)
        save()
    }

    func setEnabled(_ service: ServiceDefinition, isEnabled: Bool) {
        service.isEnabled = isEnabled
        save()
    }

    func move(_ services: [ServiceDefinition], fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = services
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, service) in reordered.enumerated() {
            service.sortOrder = index
        }
        save()
    }

    func updateStatus(_ service: ServiceDefinition, status: HealthStatus) {
        service.lastStatus = status
        service.lastPolled = .now
        save()
    }

    private func save() {
        try? modelContext.save()
    }
}
