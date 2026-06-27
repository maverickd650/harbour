import SwiftUI

struct DashboardView: View {
    @Environment(ServiceRegistry.self) private var registry
    @Environment(PollingEngine.self) private var pollingEngine
    @State private var services: [ServiceDefinition] = []
    @State private var isShowingAddService = false

    private var topAlert: (service: ServiceDefinition, status: HealthStatus)? {
        services
            .compactMap { service -> (ServiceDefinition, HealthStatus)? in
                guard service.lastStatus.message != nil else { return nil }
                return (service, service.lastStatus)
            }
            .max { lhs, rhs in severityRank(lhs.1) < severityRank(rhs.1) }
    }

    private func severityRank(_ status: HealthStatus) -> Int {
        switch status {
        case .error: return 2
        case .warning: return 1
        case .ok, .unknown: return 0
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HealthStripView(services: services)

                    if let topAlert, let message = topAlert.status.message {
                        AlertBannerView(serviceName: topAlert.service.displayName, message: message, status: topAlert.status)
                            .padding(.horizontal, 16)
                    }

                    MiniWidgetRow(stats: [])

                    VStack(spacing: 10) {
                        ForEach(services) { service in
                            ServiceCardView(service: service)
                        }
                    }
                    .padding(.horizontal, 16)

                    if services.isEmpty {
                        emptyState
                    }
                }
                .padding(.bottom, 24)
            }
            .background(AppColors.background)
            .navigationTitle("Harbour")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddService = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await pollingEngine.refreshAll()
                reload()
            }
            .sheet(isPresented: $isShowingAddService, onDismiss: reload) {
                AddServiceSheet()
            }
            .onAppear(perform: reload)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "server.rack")
                .font(.largeTitle)
                .foregroundStyle(AppColors.textSecondary)
            Text("No services yet")
                .foregroundStyle(AppColors.textPrimary)
            Text("Tap + to add your first service by URL.")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func reload() {
        services = registry.fetchAll()
    }
}

private struct AlertBannerView: View {
    let serviceName: String
    let message: String
    let status: HealthStatus

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(serviceName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(12)
        .background(AppColors.card)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(status.color.opacity(0.4), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
