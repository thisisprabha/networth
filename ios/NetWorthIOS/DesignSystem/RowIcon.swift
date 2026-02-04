import SwiftUI

struct RowIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.icon, style: .continuous)
            .fill(color.opacity(0.15))
            .overlay(
                Image(systemName: systemName)
                    .foregroundStyle(color)
            )
            .frame(width: Theme.Size.icon, height: Theme.Size.icon)
    }
}
