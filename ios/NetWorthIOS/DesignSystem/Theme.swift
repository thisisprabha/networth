import SwiftUI

enum Theme {
    enum Spacing {
        static let xSmall: CGFloat = 4
        static let tight: CGFloat = 6
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
        static let xxxLarge: CGFloat = 32
        static let screenHorizontal: CGFloat = 16
        static let screenVertical: CGFloat = 12
        static let cardPadding: CGFloat = 16
    }

    enum Radius {
        static let card: CGFloat = 20
        static let hero: CGFloat = 28
        static let icon: CGFloat = 12
        static let pill: CGFloat = 999
    }

    enum Elevation {
        static let cardShadowColor = Color.black.opacity(0.08)
        static let cardShadowRadius: CGFloat = 16
        static let cardShadowY: CGFloat = 8
        static let heroShadowColor = Color.black.opacity(0.15)
        static let heroShadowRadius: CGFloat = 24
        static let heroShadowY: CGFloat = 12
    }

    enum Size {
        static let icon: CGFloat = 36
        static let heroHeight: CGFloat = 200
        static let chartSmall: CGFloat = 110
        static let chartMedium: CGFloat = 120
        static let appLockCardMaxWidth: CGFloat = 320
    }

    enum Gradients {
        static let heroMeshColors: [Color] = [
            Color(red: 0.05, green: 0.18, blue: 0.15),
            Color(red: 0.08, green: 0.28, blue: 0.20),
            Color(red: 0.10, green: 0.40, blue: 0.28),
            Color(red: 0.12, green: 0.36, blue: 0.30),
            Color(red: 0.18, green: 0.52, blue: 0.36),
            Color(red: 0.30, green: 0.64, blue: 0.48),
            Color(red: 0.40, green: 0.72, blue: 0.58),
            Color(red: 0.58, green: 0.82, blue: 0.70),
            Color(red: 0.78, green: 0.92, blue: 0.84)
        ]
        static let heroLinearColors: [Color] = [
            Color(red: 0.05, green: 0.18, blue: 0.15),
            Color(red: 0.14, green: 0.45, blue: 0.34),
            Color(red: 0.55, green: 0.82, blue: 0.68)
        ]
    }

    enum Typography {
        static let heroValue = AppFont.custom(size: 40, weight: .bold, relativeTo: .largeTitle)
        static let lockIcon = Font.system(size: 36, weight: .bold)
    }

    static let background = Color.white
    static let card = Color.white
    static let accent = Color(red: 0.98, green: 0.77, blue: 0.22)
    static let accentAlt = Color(red: 0.98, green: 0.58, blue: 0.24)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let divider = Color(.separator)
    static let positive = Color(red: 0.10, green: 0.65, blue: 0.42)
    static let negative = Color(.systemRed)
}
