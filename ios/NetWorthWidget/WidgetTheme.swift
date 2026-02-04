import SwiftUI

enum WidgetTheme {
    static let gradientColors: [Color] = [
        Color(red: 0.05, green: 0.18, blue: 0.15),
        Color(red: 0.18, green: 0.52, blue: 0.36),
        Color(red: 0.78, green: 0.92, blue: 0.84)
    ]

    static let titleFont = Font.caption
    static let valueFont = Font.system(size: 24, weight: .bold, design: .rounded)
    static let deltaFont = Font.caption.bold()
    static let footnoteFont = Font.caption2
}
