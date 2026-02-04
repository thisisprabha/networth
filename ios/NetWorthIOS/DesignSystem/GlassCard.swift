import SwiftUI

struct GlassCard<Content: View>: View {
    var isInteractive: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26, *) {
            content
                .padding(Theme.Spacing.cardPadding)
                .background(Theme.card, in: .rect(cornerRadius: Theme.Radius.card))
                .glassEffect(isInteractive ? .regular.interactive() : .regular, in: .rect(cornerRadius: Theme.Radius.card))
        } else {
            content
                .padding(Theme.Spacing.cardPadding)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: Theme.Radius.card))
        }
    }
}
