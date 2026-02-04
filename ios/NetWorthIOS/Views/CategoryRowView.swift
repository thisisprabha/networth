import SwiftUI

struct CategoryRowView: View {
    let summary: CategorySummary

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            RowIcon(systemName: summary.category.definition.symbolName, color: summary.category.definition.color)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(summary.category.definition.name)
                    .font(AppFont.font(.subheadline, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                if summary.category.definition.isLiability {
                    Text("Debt")
                        .font(AppFont.font(.caption))
                        .foregroundStyle(Theme.secondaryText)
                } else if let percentage = summary.percentage {
                    Text(percentage, format: .percent.precision(.fractionLength(0)))
                        .font(AppFont.font(.caption))
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    Text("Coverage")
                        .font(AppFont.font(.caption))
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer()

            let isLiability = summary.category.definition.isLiability
            let valueText = (isLiability ? "-" : "") + Formatters.formatINR(summary.total)
            Text(valueText)
                .font(AppFont.font(.subheadline, weight: .semibold))
                .foregroundStyle(isLiability ? Theme.negative : Theme.primaryText)
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}
