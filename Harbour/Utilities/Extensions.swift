import SwiftUI

extension Color {
    /// Builds a `Color` from a 6-digit hex string, e.g. `"0a0a0a"`.
    init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if sanitized.count != 6 {
            sanitized = "000000"
        }
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

extension HealthStatus {
    var color: Color { Color(hex: dotColorHex) }
}
