import SwiftUI

struct GlassCard<Content: View>: View {
    var isInteractive: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26, *) {
            content
                .padding()
                .background(Theme.card, in: .rect(cornerRadius: 20))
                .glassEffect(isInteractive ? .regular.interactive() : .regular, in: .rect(cornerRadius: 20))
        } else {
            content
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
        }
    }
}
