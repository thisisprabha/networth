import SwiftUI

struct AssetRowView: View {
    let asset: Asset
    let value: Double

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(asset.category.definition.color.opacity(0.15))
                Image(systemName: asset.category.definition.symbolName)
                    .foregroundStyle(asset.category.definition.color)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)
                if let detail = asset.textValue("assetName"), !detail.isEmpty {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer()

            Text(Formatters.formatINR(value))
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
        }
        .padding(.vertical, 6)
    }
}
