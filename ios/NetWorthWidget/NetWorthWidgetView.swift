import SwiftUI
import WidgetKit

struct NetWorthWidgetView: View {
    let entry: NetWorthEntry

    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    backgroundGradient
                }
        } else {
            content
                .background(backgroundGradient)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Net Worth")
                .font(WidgetTheme.titleFont)
                .foregroundStyle(.white.opacity(0.8))

            Text(Formatters.formatMoney(entry.state.netWorth, config: moneyConfig))
                .font(WidgetTheme.valueFont)
                .foregroundStyle(.white)
                .lineLimit(1)

            if let delta = entry.state.deltaPercent {
                Text(delta, format: .percent.precision(.fractionLength(1)))
                    .font(WidgetTheme.deltaFont)
                    .foregroundStyle(.white)
            } else {
                Text("Update to see change")
                    .font(WidgetTheme.footnoteFont)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Text(entry.state.lastUpdated, style: .date)
                .font(WidgetTheme.footnoteFont)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: WidgetTheme.gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var moneyConfig: MoneyFormatConfig {
        MoneyFormatConfig(currencyCode: entry.state.currencyCode, regionCode: entry.state.regionCode)
    }
}
