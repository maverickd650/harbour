import SwiftUI

struct ServiceListView: View {
    @Environment(ServiceRegistry.self) private var registry
    @State private var services: [ServiceDefinition] = []

    var body: some View {
        List {
            ForEach(services) { service in
                HStack {
                    Image(systemName: service.type.systemImageName)
                        .foregroundStyle(AppColors.textSecondary)
                    VStack(alignment: .leading) {
                        Text(service.displayName)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(service.baseURL.host() ?? service.baseURL.absoluteString)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { service.isEnabled },
                        set: { registry.setEnabled(service, isEnabled: $0); reload() }
                    ))
                    .labelsHidden()
                }
                .listRowBackground(AppColors.card)
            }
            .onMove { source, destination in
                registry.move(services, fromOffsets: source, toOffset: destination)
                reload()
            }
            .onDelete { offsets in
                for index in offsets { registry.remove(services[index]) }
                reload()
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .navigationTitle("Services")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { EditButton() }
        }
        .onAppear(perform: reload)
    }

    private func reload() {
        services = registry.fetchAll()
    }
}
