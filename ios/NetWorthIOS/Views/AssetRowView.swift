import SwiftUI

struct AssetRowView: View {
    let asset: Asset
    let value: Double

    var body: some View {
        let isLiability = asset.category.definition.isLiability
        let valueText = (isLiability ? "-" : "") + Formatters.formatINR(value)

        HStack(spacing: Theme.Spacing.medium) {
            RowIcon(systemName: asset.category.definition.symbolName, color: asset.category.definition.color)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(asset.name)
                    .font(AppFont.font(.subheadline, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                if let detail = asset.textValue("assetName"), !detail.isEmpty {
                    Text(detail)
                        .font(AppFont.font(.caption))
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer()

            Text(valueText)
                .font(AppFont.font(.subheadline, weight: .semibold))
                .foregroundStyle(isLiability ? Theme.negative : Theme.primaryText)
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}
