import SwiftUI

struct MiniStat: Identifiable {
    let id = UUID()
    let systemImage: String
    let label: String
    let value: String
}

/// WAN speed / active Plex stream / commit count at a glance. Empty until the
/// Unifi, Plex, and GitHub clients land — see HANDOVER.md build order.
struct MiniWidgetRow: View {
    let stats: [MiniStat]

    var body: some View {
        if stats.isEmpty {
            EmptyView()
        } else {
            HStack(spacing: 10) {
                ForEach(stats) { stat in
                    HStack(spacing: 6) {
                        Image(systemName: stat.systemImage)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(stat.value)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(stat.label)
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.card)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.border, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}
