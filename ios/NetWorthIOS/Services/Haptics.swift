import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum Haptics {
    static func success() {
        notify(.success)
    }

    static func warning() {
        notify(.warning)
    }

    static func error() {
        notify(.error)
    }

    static func light() {
        impact(.light)
    }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
        #endif
    }

    private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}
