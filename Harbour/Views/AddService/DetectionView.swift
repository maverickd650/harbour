import SwiftUI

enum DetectionState {
    case idle
    case probing
    case found(DetectedService)
    case notFound
}

/// Animated probe sequence shown while `ServiceDetector` races requests against
/// the pasted URL.
struct DetectionView: View {
    let state: DetectionState

    var body: some View {
        VStack(spacing: 10) {
            switch state {
            case .idle:
                EmptyView()

            case .probing:
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppColors.textSecondary)
                    Text("Probing known service paths\u{2026}")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.card)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            case .found(let detected):
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(hex: "2ECC71"))
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Detected: \(detected.type.displayName)")
                            .foregroundStyle(AppColors.textPrimary)
                        if let detail = detected.detailLine {
                            Text(detail)
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    Spacer()
                }
                .padding(14)
                .background(AppColors.card)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "2ECC71").opacity(0.4), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            case .notFound:
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(hex: "E5484D"))
                        .frame(width: 8, height: 8)
                    Text("No known service responded at that URL.")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                }
                .padding(14)
                .background(AppColors.card)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFoundOrNotFound)
    }

    private var isFoundOrNotFound: Bool {
        switch state {
        case .found, .notFound: return true
        default: return false
        }
    }
}
