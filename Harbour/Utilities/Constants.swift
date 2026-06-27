import SwiftUI

/// Dark, minimal — no gradients, no blur. This is for one person; infrastructure
/// software register, not App Store screenshot energy.
enum AppColors {
    static let background = Color(hex: "0a0a0a")
    static let card = Color(hex: "111111")
    static let border = Color(hex: "222222")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "888888")
}

enum AppConstants {
    static let defaultPollingInterval: TimeInterval = 60
    static let probeTimeout: TimeInterval = 5
}
