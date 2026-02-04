import SwiftUI

struct CardContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .fill(Theme.card)
                    .shadow(
                        color: Theme.Elevation.cardShadowColor,
                        radius: Theme.Elevation.cardShadowRadius,
                        x: 0,
                        y: Theme.Elevation.cardShadowY
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .stroke(Theme.divider.opacity(0.2), lineWidth: 1)
            )
    }
}
