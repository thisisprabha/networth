import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum AppFont {
    static let regularName = "iAWriterQuattroS-Regular"
    static let boldName = "iAWriterQuattroS-Bold"

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let name = fontName(for: weight)
        #if canImport(UIKit)
        let size = UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
        return .custom(name, size: size, relativeTo: style)
        #else
        return .custom(name, size: 17, relativeTo: style)
        #endif
    }

    static func custom(size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle) -> Font {
        .custom(fontName(for: weight), size: size, relativeTo: style)
    }

    private static func fontName(for weight: Font.Weight) -> String {
        switch weight {
        case .bold, .semibold:
            return boldName
        default:
            return regularName
        }
    }
}

#if canImport(UIKit)
private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
#endif
