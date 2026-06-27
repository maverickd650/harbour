import SwiftUI
import SwiftData

@main
struct HarbourApp: App {
    let modelContainer: ModelContainer
    @State private var registry: ServiceRegistry
    @State private var pollingEngine: PollingEngine

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: ServiceDefinition.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        modelContainer = container

        let registry = ServiceRegistry(modelContext: container.mainContext)
        _registry = State(initialValue: registry)
        _pollingEngine = State(initialValue: PollingEngine(registry: registry))
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .tint(AppColors.textPrimary)
            .environment(registry)
            .environment(pollingEngine)
            .task {
                pollingEngine.start()
            }
        }
        .modelContainer(modelContainer)
    }
}
