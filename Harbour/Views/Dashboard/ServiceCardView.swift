import SwiftUI

/// Tap to reveal key metrics per service. Detailed per-type metrics land once
/// the remaining API clients are implemented — see HANDOVER.md build order.
struct ServiceCardView: View {
    let service: ServiceDefinition
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Circle()
                        .fill(service.lastStatus.color)
                        .frame(width: 8, height: 8)

                    Image(systemName: service.type.systemImageName)
                        .foregroundStyle(AppColors.textSecondary)

                    Text(service.displayName)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    if let message = service.lastStatus.message {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    if let lastPolled = service.lastPolled {
                        Text("Last polled \(lastPolled.formatted(.relative(presentation: .named)))")
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Text(service.baseURL.host() ?? service.baseURL.absoluteString)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .transition(.opacity)
            }
        }
        .padding(14)
        .background(AppColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
