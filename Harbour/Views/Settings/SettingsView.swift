import SwiftUI

struct SettingsView: View {
    @Environment(PollingEngine.self) private var pollingEngine

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Services") {
                        ServiceListView()
                    }
                } footer: {
                    Text("Reorder, enable/disable, or remove a service.")
                        .foregroundStyle(AppColors.textSecondary)
                }
                .listRowBackground(AppColors.card)

                Section("Polling") {
                    HStack {
                        Text("Interval")
                        Spacer()
                        Text("\(Int(pollingEngine.refreshInterval))s")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .listRowBackground(AppColors.card)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Settings")
        }
    }
}
