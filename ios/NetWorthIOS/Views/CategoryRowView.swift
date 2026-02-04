import SwiftUI

struct CategoryRowView: View {
    let summary: CategorySummary

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(summary.category.definition.color.opacity(0.15))
                Image(systemName: summary.category.definition.symbolName)
                    .foregroundStyle(summary.category.definition.color)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(summary.category.definition.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)
                if summary.category.definition.isLiability {
                    Text("Debt")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                } else if let percentage = summary.percentage {
                    Text(percentage, format: .percent.precision(.fractionLength(0)))
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    Text("Coverage")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer()

            Text(Formatters.formatINR(summary.total))
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
        }
        .padding(.vertical, 4)
    }
}
