import SwiftUI

/// Compact coloured dots, one per service, always visible at the top of the dashboard.
struct HealthStripView: View {
    let services: [ServiceDefinition]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(services) { service in
                VStack(spacing: 4) {
                    Circle()
                        .fill(service.lastStatus.color)
                        .frame(width: 8, height: 8)
                    Text(service.displayName)
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
